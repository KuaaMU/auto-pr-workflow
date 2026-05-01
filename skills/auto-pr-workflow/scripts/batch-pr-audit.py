#!/usr/bin/env python3
"""Batch PR audit: event-driven PR status monitoring for auto-pr-workflow.

Usage: python3 batch-pr-audit.py [--state open|closed|merged]

Reads PRs via `gh search prs`, then checks each PR's details.
Output: categorized report with events (approved / needs-action / has-feedback / 
        no-activity / conflicting / stale / ci-failure / merge-rate-alert).

This script serves as the PR Watchdog data layer — stdout is injected into
the cron agent prompt for action decisions.
"""
import json
import subprocess
import sys
import os
import re
from datetime import datetime, timezone

# ── Config ──────────────────────────────────────────────
OWN_REPOS = {"KuaaMU/omnihive", "KuaaMU/auto-pr-workflow", "KuaaMU/clay"}
STALE_DAYS = 7
MERGE_RATE_THRESHOLD = 0.10  # 10%
PR_LOG_PATH = os.path.expanduser("~/.hermes/skills/auto-pr-workflow/PR-LOG.md")

# Unset proxy vars that break gh/curl TLS
for var in ["ALL_PROXY", "HTTPS_PROXY", "HTTP_PROXY", "HTTP_PROXY_URL"]:
    os.environ.pop(var, None)

def run(cmd):
    r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=60)
    return r.stdout.strip(), r.stderr.strip(), r.returncode

def get_open_prs():
    out, err, rc = run('gh search prs --author=@me --state=open --limit 50 --json repository,number,title,updatedAt,url')
    if rc != 0:
        print(f"❌ Failed to list PRs: {err}")
        sys.exit(1)
    prs = json.loads(out)
    return [p for p in prs if p['repository']['nameWithOwner'] not in OWN_REPOS]

def get_pr_details(repo, num):
    out, err, rc = run(f'gh pr view {num} --repo {repo} --json reviews,comments,mergeable,state,title,labels,commits')
    if rc != 0:
        return None
    return json.loads(out)

def get_ci_status(repo, num):
    out, err, rc = run(f'gh pr checks {num} --repo {repo}')
    lines = out.split('\n') if out else []
    passing = sum(1 for l in lines if '\tpass\t' in l)
    failing = sum(1 for l in lines if '\tfail\t' in l)
    pending = sum(1 for l in lines if '\tpending\t' in l or '\tqueued\t' in l)
    total = passing + failing + pending
    # Filter out expected failures (Vercel fork auth etc.)
    real_fails = [l for l in lines if '\tfail\t' in l 
                  and 'Authorization required' not in l 
                  and 'vercel' not in l.lower()]
    return {
        "passing": passing, "failing": failing, "pending": pending, 
        "total": total, "real_fails": len(real_fails), "raw": lines[:5]
    }

def check_inline_comments(repo, num):
    """Check for recent inline review comments (CodeRabbit, Copilot, etc.)"""
    out, err, rc = run(f'gh api repos/{repo}/pulls/{num}/comments 2>/dev/null')
    if rc != 0 or not out:
        return []
    try:
        comments = json.loads(out)
        return comments[-5:] if comments else []
    except:
        return []

def get_merge_rate():
    """Calculate merge rate from PR-LOG.md"""
    try:
        with open(PR_LOG_PATH, 'r') as f:
            content = f.read()
        total_match = re.search(r'\*\*总计\*\*:\s*(\d+)', content)
        merged_match = re.search(r'\*\*已合并\*\*:\s*(\d+)', content)
        if total_match and merged_match:
            total = int(total_match.group(1))
            merged = int(merged_match.group(1))
            if total > 0:
                return merged, total, merged / total
    except:
        pass
    return 0, 0, 0.0

def detect_merges():
    """Detect recently merged/closed PRs not yet in PR-LOG.
    
    Returns list of events for newly detected merges/closures.
    """
    events = []
    
    # 1. Get recently closed PRs
    out, err, rc = run('gh search prs --author=@me --state=closed --limit 15 --json repository,number,title,url,closedAt')
    if rc != 0 or not out:
        return events
    
    try:
        closed_prs = json.loads(out)
    except:
        return events
    
    # Filter out own repos
    closed_prs = [p for p in closed_prs if p['repository']['nameWithOwner'] not in OWN_REPOS]
    
    # 2. Read PR-LOG to find which PRs are marked as open
    try:
        with open(PR_LOG_PATH, 'r') as f:
            log_content = f.read()
    except:
        return events
    
    # Find all PR references in PR-LOG that are marked as 🟢 open
    # Pattern: | N | project | lang | [#num](url) | desc | date | 🟢 open | notes |
    open_pattern = re.compile(r'\|\s*\d+\s*\|[^|]*\|[^|]*\|\s*\[#(\d+)\]\(([^)]+)\)[^|]*\|[^|]*\|[^|]*\|\s*🟢 open\s*\|')
    open_in_log = {}
    for m in open_pattern.finditer(log_content):
        num = m.group(1)
        url = m.group(2)
        # Extract repo from URL: https://github.com/owner/repo/pull/123
        url_match = re.search(r'github\.com/([^/]+/[^/]+)/pull/', url)
        if url_match:
            repo = url_match.group(1)
            open_in_log[f"{repo}#{num}"] = url
    
    # 3. Compare: closed PRs that are still marked open in PR-LOG
    for pr in closed_prs:
        repo = pr['repository']['nameWithOwner']
        num = str(pr['number'])
        key = f"{repo}#{num}"
        title = pr.get('title', '')[:60]
        url = pr.get('url', '')
        closed_at = pr.get('closedAt', '')
        
        if key in open_in_log:
            # PR was open in log but now closed — check if merged or rejected
            # Use API events endpoint for reliable merge detection (handles squash merge)
            events_out, _, events_rc = run(f'gh api repos/{repo}/issues/{num}/events 2>/dev/null')
            if events_rc == 0 and events_out:
                try:
                    pr_events = json.loads(events_out)
                    merged_events = [e for e in pr_events if e.get('event') == 'merged']
                    closed_events = [e for e in pr_events if e.get('event') == 'closed']
                    
                    if merged_events:
                        events.append({
                            "type": "newly_merged", "priority": "high",
                            "msg": f"✅ {repo} #{num} 已合并！({title}) — 需要更新 PR-LOG"
                        })
                    elif closed_events:
                        close_event = closed_events[0]
                        commit_id = close_event.get('commit_id', '')
                        if commit_id:
                            events.append({
                                "type": "newly_merged", "priority": "high",
                                "msg": f"✅ {repo} #{num} 已合并（squash）！({title}) — 需要更新 PR-LOG"
                            })
                        else:
                            events.append({
                                "type": "newly_closed", "priority": "high",
                                "msg": f"❌ {repo} #{num} 已关闭/拒绝 ({title}) — 需要更新 PR-LOG"
                            })
                except:
                    pass
    
    # 4. Also check for closed PRs not in PR-LOG at all (missed merges)
    all_log_keys = set(re.findall(r'github\.com/([^/]+/[^/]+)/pull/(\d+)', log_content))
    all_log_keys = {f"{repo}#{num}" for repo, num in all_log_keys}
    
    for pr in closed_prs:
        repo = pr['repository']['nameWithOwner']
        num = str(pr['number'])
        key = f"{repo}#{num}"
        title = pr.get('title', '')[:60]
        
        if key not in all_log_keys:
            # Closed PR not tracked in PR-LOG at all
            detail_out, _, detail_rc = run(f'gh pr view {num} --repo {repo} --json mergedAt,state 2>/dev/null')
            if detail_rc == 0 and detail_out:
                try:
                    detail = json.loads(detail_out)
                    if detail.get('mergedAt'):
                        events.append({
                            "type": "untracked_merged", "priority": "medium",
                            "msg": f"🆕 {repo} #{num} 已合并但未在 PR-LOG 中！({title})"
                        })
                except:
                    pass
    
    return events

def categorize(prs_data, now):
    """Categorize PRs and detect events."""
    cats = {
        "approved": [], "needs_action": [], "has_feedback": [], 
        "no_activity": [], "conflicting": [], "stale": []
    }
    events = []
    
    for p in prs_data:
        d = p["details"]
        ci = p["ci"]
        repo = p["repo"]
        num = p["num"]
        title = p.get("title", "")[:60]
        
        # Days since update
        updated = p.get("updatedAt", "")
        try:
            updated_dt = datetime.fromisoformat(updated.replace('Z', '+00:00'))
            days_since = (now - updated_dt).days
        except:
            days_since = 999
        
        if not d:
            cats["no_activity"].append(p)
            continue

        reviews = d.get("reviews", [])
        review_states = [r.get("state", "") for r in reviews]
        has_approved = "APPROVED" in review_states
        has_changes = "CHANGES_REQUESTED" in review_states
        comment_count = len(d.get("comments", []))
        mergeable = d.get("mergeable", "UNKNOWN")

        # ── Event detection ──
        
        # Conflicting
        if mergeable == "CONFLICTING":
            cats["conflicting"].append(p)
            events.append({
                "type": "conflicting", "priority": "high",
                "msg": f"🔀 {repo} #{num} 有合并冲突: {title}"
            })
        
        # CI failure (real, not expected fork failures)
        if ci.get("real_fails", 0) > 0:
            cats["needs_action"].append(p)
            events.append({
                "type": "ci_failure", "priority": "high",
                "msg": f"❌ {repo} #{num} CI 失败 ({ci['real_fails']} checks): {title}"
            })
        elif has_changes:
            cats["needs_action"].append(p)
            events.append({
                "type": "changes_requested", "priority": "high",
                "msg": f"⚠️ {repo} #{num} 有修改请求: {title}"
            })
        elif has_approved and mergeable == "MERGEABLE":
            cats["approved"].append(p)
            events.append({
                "type": "approved_ready", "priority": "medium",
                "msg": f"✅ {repo} #{num} 已 approved 且可合并: {title}"
            })
        elif comment_count > 0 or any(s == "COMMENTED" for s in review_states):
            cats["has_feedback"].append(p)
        else:
            cats["no_activity"].append(p)
        
        # Stale detection
        if days_since > STALE_DAYS:
            if p not in cats["stale"]:
                cats["stale"].append(p)
            prio = "medium" if days_since < 14 else "high"
            events.append({
                "type": "stale_pr", "priority": prio,
                "msg": f"💤 {repo} #{num} 已 {days_since} 天无更新: {title}"
            })
    
    # Merge rate check
    merged, total, rate = get_merge_rate()
    if total > 0 and rate < MERGE_RATE_THRESHOLD:
        events.append({
            "type": "merge_rate_alert", "priority": "critical",
            "msg": f"🚨 合并率 {rate:.1%}（{merged}/{total}）低于 {MERGE_RATE_THRESHOLD:.0%} 阈值。建议停止新 PR，优先推动已有 PR 合并。"
        })
    
    # Sort events by priority
    priority_order = {"critical": 0, "high": 1, "medium": 2, "low": 3}
    events.sort(key=lambda e: priority_order.get(e.get('priority', 'low'), 3))
    
    return cats, events

def main():
    now = datetime.now(timezone.utc)
    print(f"🔍 Fetching open PRs... ({now.strftime('%Y-%m-%d %H:%M UTC')})")
    prs = get_open_prs()
    # Filter out own repos
    prs = [p for p in prs if p['repository']['nameWithOwner'] not in OWN_REPOS]
    print(f"Found {len(prs)} external open PRs\n")

    results = []
    for pr in prs:
        repo = pr["repository"]["nameWithOwner"]
        num = pr["number"]
        sys.stdout.write(f"  Checking {repo} #{num}...\r")
        sys.stdout.flush()

        details = get_pr_details(repo, num)
        ci = get_ci_status(repo, num)
        inline = check_inline_comments(repo, num)
        results.append({
            "repo": repo, "num": num, "title": pr.get("title", ""),
            "url": pr.get("url", ""), "updatedAt": pr.get("updatedAt", ""),
            "details": details, "ci": ci, "inline_comments": inline,
        })

    cats, events = categorize(results, now)

    # ── Output ──
    print(f"\n{'=' * 60}")
    print(f"📊 PR WATCHDOG REPORT ({len(results)} external open PRs)")
    print(f"{'=' * 60}")

    if cats["approved"]:
        print(f"\n✅ READY TO MERGE ({len(cats['approved'])})")
        for e in cats["approved"]:
            print(f"  {e['repo']} #{e['num']} — {e['title'][:60]}")
            print(f"    CI: {e['ci']['passing']}/{e['ci']['total']} passing | {e['url']}")

    if cats["needs_action"]:
        print(f"\n⚠️ NEEDS ACTION ({len(cats['needs_action'])})")
        for e in cats["needs_action"]:
            d = e["details"]
            reviews = d.get("reviews", []) if d else []
            change_reqs = [r for r in reviews if r.get("state") == "CHANGES_REQUESTED"]
            print(f"  {e['repo']} #{e['num']} — {e['title'][:60]}")
            if e['ci']['real_fails'] > 0:
                print(f"    CI: {e['ci']['real_fails']} real failures")
            if change_reqs:
                print(f"    Changes requested by: {[r.get('author',{}).get('login','?') for r in change_reqs]}")
            print(f"    {e['url']}")

    if cats["conflicting"]:
        print(f"\n🔀 CONFLICTING ({len(cats['conflicting'])})")
        for e in cats["conflicting"]:
            print(f"  {e['repo']} #{e['num']} — {e['title'][:60]} | {e['url']}")

    if cats["stale"]:
        print(f"\n💤 STALE (> {STALE_DAYS} days) ({len(cats['stale'])})")
        for e in cats["stale"]:
            print(f"  {e['repo']} #{e['num']} — {e['title'][:60]} | {e['url']}")

    if cats["has_feedback"]:
        print(f"\n💬 HAS FEEDBACK ({len(cats['has_feedback'])})")
        for e in cats["has_feedback"]:
            d = e["details"]
            comments = d.get("comments", []) if d else []
            print(f"  {e['repo']} #{e['num']} — {e['title'][:60]}")
            print(f"    {len(comments)} comments | CI: {e['ci']['passing']}/{e['ci']['total']} | {e['url']}")

    if cats["no_activity"]:
        print(f"\n📭 NO ACTIVITY ({len(cats['no_activity'])})")
        for e in cats["no_activity"]:
            ci_note = f"CI: {e['ci']['passing']}/{e['ci']['total']}" if e['ci']['total'] > 0 else "No CI"
            print(f"  {e['repo']} #{e['num']} — {ci_note}")

    # Inline comments summary
    with_comments = [r for r in results if r.get("inline_comments")]
    if with_comments:
        print(f"\n📝 INLINE REVIEW COMMENTS ({len(with_comments)} PRs)")
        for e in with_comments:
            print(f"  {e['repo']} #{e['num']} — {len(e['inline_comments'])} recent comments")

    print(f"\n{'=' * 60}")
    print(f"Summary: ✅{len(cats['approved'])} ⚠️{len(cats['needs_action'])} 💬{len(cats['has_feedback'])} 🔀{len(cats['conflicting'])} 💤{len(cats['stale'])} 📭{len(cats['no_activity'])}")

    # ── Events for agent ──
    
    # ── Merge detection (check closed PRs vs PR-LOG) ──
    merge_events = detect_merges()
    if merge_events:
        print(f"\n🔄 MERGE/CLOSE DETECTION ({len(merge_events)} events)")
        for e in merge_events:
            print(f"  {e['msg']}")
        events.extend(merge_events)
    
    if events:
        print(f"\n--- EVENTS (priority-sorted) ---")
        for e in events:
            print(e['msg'])
        
        critical = [e for e in events if e.get('priority') == 'critical']
        high = [e for e in events if e.get('priority') == 'high']
        medium = [e for e in events if e.get('priority') == 'medium']
        
        print(f"\n--- SUGGESTED ACTIONS ---")
        if critical:
            print("🔴 立即处理：")
            for e in critical:
                print(f"  - {e['msg']}")
        if high:
            print("🟠 优先处理：")
            for e in high:
                print(f"  - {e['msg']}")
        if medium:
            print("🟡 适时处理：")
            for e in medium:
                print(f"  - {e['msg']}")
    else:
        print("\n✅ 无需干预，所有 PR 状态正常。")

if __name__ == "__main__":
    main()
