# Memory Architecture Manager

优化 OpenClaw 记忆架构：Layer 1 本地文件 + Layer 2 插件 + Layer 3 可选深度归档。

## 核心功能

### 综合优化

```bash
bash ~/.openclaw/skills/memory-architecture-manager/scripts/optimize-memory-architecture.sh
```

### 单独检查

```bash
# Layer 2 健康检查
bash ~/.openclaw/skills/memory-architecture-manager/scripts/layer2-health-check.sh

# 记忆质量审计
bash ~/.openclaw/skills/memory-architecture-manager/scripts/memory-quality-audit.sh
```

---

## 记忆架构

### Layer 1（必需）

本地文件系统：
- `memory/` — 每日记忆
- `memory/topics/` — 主题记忆
- `MEMORY.md` — 长期教训索引

### Layer 2A（推荐插件）

**memory-lancedb-pro** — 长期记忆、向量检索、跨会话检索

```bash
openclaw plugins install memory-lancedb-pro@beta
```

### Layer 2B（推荐插件）

**lossless-claw-enhanced** — 上下文管理、DAG 摘要、Token 管理

```bash
git clone https://github.com/win4r/lossless-claw-enhanced.git
openclaw plugins install --link ./lossless-claw-enhanced
```

### Layer 3（可选）

**NotebookLM** — 深度归档、研究分析（高级用户）

---

## 脚本清单

| 脚本 | 功能 |
|------|------|
| `optimize-memory-architecture.sh` | 综合优化（Layer 1/2/3） |
| `layer2-health-check.sh` | Layer 2 健康检查 |
| `memory-quality-audit.sh` | 记忆质量审计 |
| `compress-memory.sh` | 记忆压缩 |
| `layer1-compress-check.sh` | Layer 1 压缩检查 |
| `daily-memory-report.sh` | 每日记忆报告 |

---

## 与 architecture-generator 的联动

```
architecture-generator（主入口）
    └── optimize-workspace.sh
        └── Step 5: 调用 optimize-memory-architecture.sh
```

**独立使用**：
```bash
# 直接运行记忆优化
bash optimize-memory-architecture.sh

# 直接运行 Layer 2 健康检查
bash layer2-health-check.sh
```

---

## 安装

```bash
cd ~/.openclaw/skills
git clone https://github.com/mouseroser/memory-architecture-manager-skill.git memory-architecture-manager
```

或手动下载后放到 `~/.openclaw/skills/memory-architecture-manager/`

---

**最后更新**: 2026-04-05
