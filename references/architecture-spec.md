# Memory Architecture Specification

OpenClaw 记忆架构规范（2026-04-05 通用版）。

---

## 架构概览

### Layer 1 — 文件层（必需）
- root `MEMORY.md` — 长期记忆索引
- `memory/YYYY-MM-DD.md` — 每日日志
- `shared-context/` — 跨 agent 知识共享
- `intel/` — 情报和信号

### Layer 2 — 自动记忆系统（双轨并行，可选插件）

#### Layer 2A: memory-lancedb-pro（长期记忆）
- 向量检索 + keyword + rerank
- 自动捕获 / 自动召回
- GitHub: https://github.com/CortexReach/memory-lancedb-pro

#### Layer 2B: lossless-claw-enhanced（上下文管理）
- DAG-based 摘要
- Token 管理
- CJK 友好
- GitHub: https://github.com/win4r/lossless-claw-enhanced

### Layer 3 — 深度归档（可选）
- 用户可选配置（NotebookLM / lossless-claw-enhanced / 其他）
- 长期归档 / 深度理解 / 洞察生成

---

## Layer 1 关键规则

### 1. MEMORY.md 统一骨架
所有 agent 使用同一骨架：

```
## ⚠️ 血泪教训（索引）
### <分类>
- [<标题>](memory/topics/<文件>.md)

## ✅ 验证有效的做法（Confirmed Approaches）

## 🛡️ 记忆漂移防御

## 📌 长期稳定规则

## 🌱 长期偏好
```

### 2. memory/YYYY-MM-DD.md 格式
```
[YYYY-MM-DD]

## <事件标题>

### 背景
<背景>

### 执行步骤
<步骤>

### 最终状态
<结果>

### 教训
<教训>

---

<自动捕获的记忆条目>
```

### 3. shared-context/ 目录
共享知识，不参与 Layer 2/3：
- `THESIS.md` — 当前世界观
- `FEEDBACK-LOG.md` — 跨 agent 纠偏
- `PATHS.md` — 路径索引
- `SIGNALS.md` — 信号定义
- `AGENT-FILE-ARCHITECTURE.md` — agent 文件架构

---

## Layer 2 噪音治理

### 自动记忆 vs 人工维护
- **自动记忆**: Layer 2 (memory-lancedb-pro) 自动捕获对话
- **人工维护**: Layer 1 文件由人工更新
- **职责边界**: 自动捕获不能替代人工提炼

### 召回质量监控
- 定期检查 `memory_recall` 结果相关性
- 如发现噪音，排查 Layer 2 配置

---

## Layer 3 配置说明

Layer 3 是可选的，不影响基础功能。

### 常用配置选项
1. **NotebookLM** — 云端，支持生成洞察（高级用户）
2. **lossless-claw-enhanced** — 本地 DAG 归档
3. **其他云端归档方案**

### 配置检测
```bash
# 检测 Layer 3 是否配置
if [ -d "$HOME/.openclaw/extensions/notebooklm" ]; then
    echo "Layer 3: NotebookLM 已配置"
elif [ -d "$HOME/.openclaw/extensions/lossless-claw-enhanced" ]; then
    echo "Layer 3: lossless-claw-enhanced 已配置"
else
    echo "Layer 3: 未配置"
fi
```

---

## 插件安装组合

| 组合 | Layer 2A | Layer 2B | 适用场景 |
|------|----------|----------|----------|
| 完整配置 | ✅ | ✅ | 生产环境 |
| 记忆优先 | ✅ | ❌ | 长期记忆需求 |
| 上下文优先 | ❌ | ✅ | 当前会话管理 |
| 极简配置 | ❌ | ❌ | 仅 Layer 1 |

---

**最后更新**: 2026-04-05
