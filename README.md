# Memory Architecture Manager

[![GitHub](https://img.shields.io/badge/GitHub-mouseroser-blue?logo=github)](https://github.com/mouseroser/memory-architecture-manager-skill)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-Skill-orange.svg)](https://openclaw.ai)

管理和优化 OpenClaw 三层记忆架构的专业工具。

## ✨ 特性

- 📁 **Layer 1 管理** - 本地文件系统记忆优化
- 🔌 **Layer 2 检测** - 自动检测插件安装状态
- 🏥 **健康检查** - 定期检查记忆系统健康状态
- 📊 **质量审计** - 记忆质量分析和优化建议
- 🗜️ **智能压缩** - 自动压缩和归档历史记忆

## 🚀 快速开始

### 安装

```bash
cd ~/.openclaw/skills
git clone https://github.com/mouseroser/memory-architecture-manager-skill.git memory-architecture-manager
```

### 使用

```bash
# 综合优化（推荐）
bash ~/.openclaw/skills/memory-architecture-manager/scripts/optimize-memory-architecture.sh

# Layer 2 健康检查
bash ~/.openclaw/skills/memory-architecture-manager/scripts/layer2-health-check.sh
```

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

## 📝 更新日志

### 2026-04-11
- 优化 README 文档
- 添加徽章和快速开始指南
- 完善记忆架构说明

### 2026-04-05
- 初始版本发布

---

## 📄 License

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📧 联系

- GitHub: [@mouseroser](https://github.com/mouseroser)
- OpenClaw Community: [Discord](https://discord.com/invite/clawd)
