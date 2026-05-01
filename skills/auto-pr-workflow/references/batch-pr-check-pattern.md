# 批量 PR 状态检查模式

## 使用场景

有 15+ 个 open PR 分散在不同仓库时，需要快速分类哪些需要行动。

## 执行步骤

### Step 1: 获取所有 open PR
```bash
gh search prs --author=@me --state=open --limit 30 \
  --json repository,number,title,createdAt,updatedAt,url \
  --jq '.[] | "\(.repository.nameWithOwner) #\(.number) | \(.title)"'
```

### Step 2: 批量获取 reviews + comments + mergeable
对每个 PR 执行：
```bash
gh pr view NUM --repo OWNER/REPO --json reviews,comments,mergeable,state,title
```

### Step 3: 分类输出

按优先级分类：

| 类别 | 判断条件 | 行动 |
|------|---------|------|
| ✅ 已批准 | reviews 中有 APPROVED | 等合并 |
| ⚠️ 需要行动 | CHANGES_REQUESTED / 有 review comments / CLA 未签 | 立即处理 |
| 💬 有反馈但无需行动 | 只有 COMMENTED reviews / bot 评论 | 观察 |
| ⚠️ 合并冲突 | mergeable == CONFLICTING | 需要 rebase |
| 📭 无活动 | 无 reviews、无 comments | 等维护者 |

### Step 4: 深入查看有反馈的 PR

对"需要行动"和"有反馈"的 PR，获取具体内容：
```bash
# 顶层评论（最后3条）
gh pr view NUM --repo OWNER/REPO --json comments

# Inline review comments（CodeRabbit、Copilot 等）
gh api repos/OWNER/REPO/pulls/NUM/comments

# CI 状态
gh pr checks NUM --repo OWNER/REPO
```

## 常见 CI 状态含义

| 状态 | 含义 | 需要行动？ |
|------|------|-----------|
| Vercel Authorization required | Fork PR 预期行为 | ❌ |
| CLA not signed | 需要签名或修复 git 身份 | ⚠️ |
| no checks reported | CI 只有 pull_request trigger | ❌ 等维护者 approve |
| autofix.ci action_required | Bot 想推送但需权限 | ❌ |

## 输出模板

```
## 📊 PR 状态整理 (DATE)

**总计：N 个 open PR**

### ✅ 等合并 (X)
| PR | 状态 |

### 🟢 CI 全绿，等 review (X)
| PR | 备注 |

### 💬 有反馈，需关注 (X)
| PR | 问题 |

### 📭 无活动 (X)
list...

### 🎯 待办
1. ...
```

## 注意事项

- 必须 `unset ALL_PROXY HTTPS_PROXY HTTP_PROXY` 否则 GitHub API 超时
- jq 模板中的花括号需要双重转义，建议用 Python json 解析代替复杂 jq
- Fork PR 的 Vercel/Netlify 部署失败是预期行为，不要报告为问题
