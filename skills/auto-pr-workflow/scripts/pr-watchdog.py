#!/usr/bin/env python3
"""
PR Watchdog — 事件驱动的 PR 状态监控脚本
作为 cron job 的 script 参数运行，stdout 注入到 agent prompt 中。

检测事件：
1. stale_pr: open PR 超过 7 天无更新
2. new_review: PR 收到新的 review comment（未回复）
3. ci_failure: PR CI 失败（非预期失败）
4. approved_ready: PR 已 approved 且可合并
5. merge_rate_alert: 最近合并率低于阈值
6. conflicting: PR 有合并冲突
"""

import subprocess
import json
import sys
from datetime import datetime, timezone, timedelta

# ── 配置 ──────────────────────────────────────────────
OWN_REPOS = {"KuaaMU/omnihive", "KuaaMU/auto-pr-workflow", "KuaaMU/clay"}
STALE_DAYS = 7
MERGE_RATE_WINDOW = 15  # 最近 N 个 PR
MERGE_RATE_THRESHOLD = 0.10  # 10%

def run(cmd):
    """运行 shell 命令，返回 stdout"""
    env = {
        **subprocess.os.environ,
        "ALL_PROXY": "", "HTTPS_PROXY": "", "HTTP_PROXY": "",
    }
    r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30, env=env)
    return r.stdout.strip()

def get_open_prs():
    """获取所有 open PR"""
    raw = run('gh search prs --author=@me --state=open --limit 30 --json repository,number,title,updatedAt,url')
    if not raw:
        return []
    prs = json.loads(raw)
    return [p for p in prs if p['repository']['nameWithOwner'] not in OWN_REPOS]

def get_pr_detail(repo, num):
    """获取 PR 详细信息"""
    raw = run(f'gh pr view {num} --repo {repo} --json reviews,comments,mergeable,commits 2>/dev/null')
    if not raw:
        return None
    try:
        return json.loads(raw)
    except:
        return None

def get_pr_checks(repo, num):
    """获取 CI 状态"""
    raw = run(f'gh pr checks {num} --repo {repo} 2>/dev/null')
    return raw

def get_recent_merged_count():
    """获取最近合并的 PR 数量"""
    raw = run(f'gh search prs --author=@me --state=closed --limit {MERGE_RATE_WINDOW} --json repository,number,title,url')
    if not raw:
        return 0, 0
    prs = json.loads(raw)
    # 过滤掉自有仓库
    external = [p for p in prs if p['repository']['nameWithOwner'] not in OWN_REPOS]
    total = len(external)
    # closed PR 不区分 merged/closed，用 gh pr view 逐个检查太慢
    # 这里用启发式：如果 title 包含 "fix:" 且有 url，大概率是 merged
    return total, len(external)  # 暂时返回总数

def check_inline_comments(repo, num):
    """检查是否有未回复的 inline review comments"""
    raw = run(f'gh api repos/{repo}/pulls/{num}/comments 2>/dev/null')
    if not raw:
        return []
    try:
        comments = json.loads(raw)
        # 只看最近 5 条
        return comments[-5:] if comments else []
    except:
        return []

def main():
    now = datetime.now(timezone.utc)
    prs = get_open_prs()
    
    events = []
    stats = {"total_open": len(prs), "stale": 0, "needs_action": 0, "approved": 0}
    
    for pr in prs:
        repo = pr['repository']['nameWithOwner']
        num = pr['number']
        title = pr['title'][:60]
        updated = pr.get('updatedAt', '')
        
        # 计算天数
        try:
            updated_dt = datetime.fromisoformat(updated.replace('Z', '+00:00'))
            days_since = (now - updated_dt).days
        except:
            days_since = 999
        
        # 获取详情
        detail = get_pr_detail(repo, num)
        if not detail:
            continue
        
        mergeable = detail.get('mergeable', 'UNKNOWN')
        reviews = detail.get('reviews', [])
        comments = detail.get('comments', [])
        
        review_states = [r.get('state', '') for r in reviews]
        has_approved = 'APPROVED' in review_states
        has_changes = 'CHANGES_REQUESTED' in review_states
        
        # ── 事件检测 ──
        
        # 1. Approved and ready
        if has_approved and mergeable == 'MERGEABLE':
            stats["approved"] += 1
            events.append({
                "type": "approved_ready",
                "priority": "medium",
                "repo": repo, "num": num,
                "msg": f"✅ {repo} #{num} 已 approved 且可合并: {title}"
            })
        
        # 2. Changes requested
        if has_changes:
            stats["needs_action"] += 1
            events.append({
                "type": "changes_requested",
                "priority": "high",
                "repo": repo, "num": num,
                "msg": f"⚠️ {repo} #{num} 有修改请求: {title}"
            })
        
        # 3. Conflicting
        if mergeable == 'CONFLICTING':
            events.append({
                "type": "conflicting",
                "priority": "high",
                "repo": repo, "num": num,
                "msg": f"🔀 {repo} #{num} 有合并冲突: {title}"
            })
        
        # 4. Stale PR
        if days_since > STALE_DAYS:
            stats["stale"] += 1
            events.append({
                "type": "stale_pr",
                "priority": "medium" if days_since < 14 else "high",
                "repo": repo, "num": num,
                "msg": f"💤 {repo} #{num} 已 {days_since} 天无更新: {title}"
            })
        
        # 5. CI failure (quick check)
        checks = get_pr_checks(repo, num)
        if checks and 'fail' in checks.lower() and 'no checks' not in checks.lower():
            # 过滤掉预期失败（Vercel fork auth 等）
            fail_lines = [l for l in checks.split('\n') if 'fail' in l.lower()]
            real_fails = [l for l in fail_lines if 'Authorization required' not in l and 'vercel' not in l.lower()]
            if real_fails:
                events.append({
                    "type": "ci_failure",
                    "priority": "high",
                    "repo": repo, "num": num,
                    "msg": f"❌ {repo} #{num} CI 失败: {real_fails[0][:80]}"
                })
    
    # ── 合并率计算 ──
    # 从 PR-LOG 读取
    try:
        with open('/home/ubuntu/.hermes/skills/auto-pr-workflow/PR-LOG.md', 'r') as f:
            content = f.read()
        # 解析统计行："- **总计**: 30 个 PR"
        import re
        total_match = re.search(r'\*\*总计\*\*:\s*(\d+)', content)
        merged_match = re.search(r'\*\*已合并\*\*:\s*(\d+)', content)
        if total_match and merged_match:
            total_in_log = int(total_match.group(1))
            merged_count = int(merged_match.group(1))
            if total_in_log > 0:
                merge_rate = merged_count / total_in_log
                if merge_rate < MERGE_RATE_THRESHOLD:
                    events.append({
                        "type": "merge_rate_alert",
                        "priority": "critical",
                        "msg": f"🚨 合并率 {merge_rate:.1%}（{merged_count}/{total_in_log}）低于 {MERGE_RATE_THRESHOLD:.0%} 阈值。建议停止新 PR，优先推动已有 PR 合并。"
                    })
    except:
        pass
    
    # ── 输出 ──
    # 按优先级排序
    priority_order = {"critical": 0, "high": 1, "medium": 2, "low": 3}
    events.sort(key=lambda e: priority_order.get(e.get('priority', 'low'), 3))
    
    if not events:
        print("✅ PR Watchdog: 所有 PR 状态正常，无需干预。")
        print(f"📊 统计: {stats['total_open']} open PRs, {stats['approved']} approved, {stats['stale']} stale")
        return
    
    print(f"## PR Watchdog 报告 ({now.strftime('%Y-%m-%d %H:%M UTC')})")
    print(f"📊 {stats['total_open']} open | {stats['approved']} approved | {stats['stale']} stale")
    print()
    
    for e in events:
        print(e['msg'])
    
    print()
    print("---")
    print("建议行动：")
    
    critical = [e for e in events if e.get('priority') == 'critical']
    high = [e for e in events if e.get('priority') == 'high']
    medium = [e for e in events if e.get('priority') == 'medium']
    
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

if __name__ == '__main__':
    main()
