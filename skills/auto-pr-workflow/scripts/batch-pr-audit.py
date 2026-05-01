#!/usr/bin/env python3
"""Batch PR audit: check CI, reviews, comments, mergeable status for all open PRs.

Usage: python3 batch-pr-audit.py [--state open|closed|merged]

Reads PRs via `gh search prs`, then checks each PR's details.
Output: categorized report (approved / needs-action / has-feedback / no-activity / conflicting).
"""
import json
import subprocess
import sys
import os

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
    return json.loads(out)

def get_pr_details(repo, num):
    out, err, rc = run(f'gh pr view {num} --repo {repo} --json reviews,comments,mergeable,state,title,labels')
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
    return {"passing": passing, "failing": failing, "pending": pending, "total": total, "raw": lines[:5]}

def categorize(prs_data):
    cats = {"approved": [], "needs_action": [], "has_feedback": [], "no_activity": [], "conflicting": []}
    for p in prs_data:
        d = p["details"]
        ci = p["ci"]
        if not d:
            cats["no_activity"].append(p)
            continue

        reviews = d.get("reviews", [])
        review_states = [r.get("state", "") for r in reviews]
        has_approved = "APPROVED" in review_states
        has_changes = "CHANGES_REQUESTED" in review_states
        comment_count = len(d.get("comments", []))
        mergeable = d.get("mergeable", "UNKNOWN")

        if mergeable == "CONFLICTING":
            cats["conflicting"].append(p)
        elif ci.get("failing", 0) > 0 or has_changes:
            cats["needs_action"].append(p)
        elif has_approved:
            cats["approved"].append(p)
        elif comment_count > 0 or any(s == "COMMENTED" for s in review_states):
            cats["has_feedback"].append(p)
        else:
            cats["no_activity"].append(p)
    return cats

def main():
    print("🔍 Fetching open PRs...")
    prs = get_open_prs()
    print(f"Found {len(prs)} open PRs\n")

    results = []
    for pr in prs:
        repo = pr["repository"]["nameWithOwner"]
        num = pr["number"]
        sys.stdout.write(f"  Checking {repo} #{num}...\r")
        sys.stdout.flush()

        details = get_pr_details(repo, num)
        ci = get_ci_status(repo, num)
        results.append({
            "repo": repo, "num": num, "title": pr.get("title", ""),
            "url": pr.get("url", ""), "details": details, "ci": ci,
        })

    cats = categorize(results)

    print("\n" + "=" * 60)
    print(f"📊 PR AUDIT REPORT ({len(results)} open PRs)")
    print("=" * 60)

    if cats["approved"]:
        print(f"\n✅ READY TO MERGE ({len(cats['approved'])})")
        for e in cats["approved"]:
            print(f"  {e['repo']} #{e['num']} — {e['title'][:60]}")
            print(f"    CI: {e['ci']['passing']}/{e['ci']['total']} passing | {e['url']}")

    if cats["needs_action"]:
        print(f"\n⚠️ NEEDS ACTION ({len(cats['needs_action'])})")
        for e in cats["needs_action"]:
            details = e["details"]
            reviews = details.get("reviews", []) if details else []
            change_reqs = [r for r in reviews if r.get("state") == "CHANGES_REQUESTED"]
            print(f"  {e['repo']} #{e['num']} — {e['title'][:60]}")
            print(f"    CI: {e['ci']['failing']} failing | Changes requested by: {[r.get('author',{}).get('login','?') for r in change_reqs]}")
            print(f"    {e['url']}")

    if cats["has_feedback"]:
        print(f"\n💬 HAS FEEDBACK ({len(cats['has_feedback'])})")
        for e in cats["has_feedback"]:
            details = e["details"]
            comments = details.get("comments", []) if details else []
            print(f"  {e['repo']} #{e['num']} — {e['title'][:60]}")
            print(f"    {len(comments)} comments | CI: {e['ci']['passing']}/{e['ci']['total']} | {e['url']}")

    if cats["conflicting"]:
        print(f"\n🔀 CONFLICTING ({len(cats['conflicting'])})")
        for e in cats["conflicting"]:
            print(f"  {e['repo']} #{e['num']} — {e['title'][:60]} | {e['url']}")

    if cats["no_activity"]:
        print(f"\n📭 NO ACTIVITY ({len(cats['no_activity'])})")
        for e in cats["no_activity"]:
            ci_note = f"CI: {e['ci']['passing']}/{e['ci']['total']}" if e['ci']['total'] > 0 else "No CI"
            print(f"  {e['repo']} #{e['num']} — {ci_note}")

    print(f"\n{'=' * 60}")
    print(f"Summary: ✅{len(cats['approved'])} ⚠️{len(cats['needs_action'])} 💬{len(cats['has_feedback'])} 🔀{len(cats['conflicting'])} 📭{len(cats['no_activity'])}")

if __name__ == "__main__":
    main()
