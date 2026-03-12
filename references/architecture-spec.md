# Architecture Specification

OpenClaw 三层记忆架构的完整规范。

---

## 架构概览

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenClaw Memory System                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Layer 1: 本地文件（人工维护）                                │
│  ├─ MEMORY.md（精华记忆）                                     │
│  ├─ memory/YYYY-MM-DD.md（每日日志）                         │
│  ├─ shared-context/（跨 agent 知识）                         │
│  └─ intel/（agent 协作）                                      │
│                                                               │
│  Layer 2: memory-lancedb-pro（自动捕获）                     │
│  ├─ 向量检索 + BM25                                          │
│  ├─ Rerank（本地 sidecar）                                   │
│  └─ Markdown mirror（备份）                                  │
│                                                               │
│  Layer 3: Memory Archive (NotebookLM)（深度理解）            │
│  ├─ 长期归档                                                  │
│  ├─ 跨会话分析                                                │
│  └─ 深度洞察                                                  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Layer 1: 本地文件

### 目录结构

```
~/.openclaw/workspace/
├── MEMORY.md                          # 精华长期记忆
├── MEMORY-ARCHITECTURE.md             # 架构说明
├── SOUL.md                            # Agent 人格
├── USER.md                            # 用户信息
├── AGENTS.md                          # Agent 配置
├── TOOLS.md                           # 工具配置
├── HEARTBEAT.md                       # 健康检查
├── memory/
│   ├── YYYY-MM-DD.md                  # 每日日志
│   ├── YYYY-MM-DD-daily.md            # 结构化日志
│   ├── archive/                       # 归档目录
│   │   ├── YYYY-MM-DD.md              # 原始文件
│   │   └── YYYY-MM-DD-compressed.md   # 压缩版本
│   └── *.md                           # 其他记忆文件
├── shared-context/
│   ├── THESIS.md                      # 当前世界观
│   ├── FEEDBACK-LOG.md                # 跨 agent 纠正
│   └── SIGNALS.md                     # 追踪趋势
├── intel/
│   ├── collaboration/                 # 多 agent 协作
│   └── *.md                           # Agent 协作文件
└── scripts/
    ├── layer1-compress-check.sh       # Layer 1 压缩检查
    └── layer2-health-check.sh         # Layer 2 健康检查
```

### 核心文件规范

#### MEMORY.md

**用途**: 精华长期记忆，启动时加载

**结构**:
```markdown
# MEMORY.md

## ⚠️ 血泪教训（永不重犯）
## ❌ 错误示范（不要这样做）
## 核心偏好
## 配置信息
## 踩坑笔记
```

**维护**:
- 人工维护
- 每周日 22:00 自动维护（Cron）
- 阈值：40k tokens

#### memory/YYYY-MM-DD.md

**用途**: 每日原始日志

**结构**:
```markdown
# YYYY-MM-DD

## 今日重点
## 完成的任务
## 学到的经验
## 待办事项
```

**维护**:
- 自动捕获 + 人工补充
- 每周日 04:00 压缩检查（Cron）
- 超过 40k tokens 自动压缩并归档

#### shared-context/THESIS.md

**用途**: 当前世界观和关注点

**结构**:
```markdown
# THESIS.md

## 我当前关注什么
## 我已经写了什么
## 还有哪些空白
## 下一步计划
```

**维护**:
- 人工维护
- 每周日回顾更新

#### shared-context/FEEDBACK-LOG.md

**用途**: 跨 agent 纠正日志

**结构**:
```markdown
# FEEDBACK-LOG.md

## 纠正日志
### [日期] [主题]
- **问题**: 
- **影响**: 
- **纠正**: 
- **状态**: 

## 通用原则
```

**维护**:
- 人工维护
- 发现跨 agent 问题时立即更新

#### shared-context/SIGNALS.md

**用途**: 追踪的趋势与信号

**结构**:
```markdown
# SIGNALS.md

## 技术趋势
## 行业动态
## 个人兴趣
## 当前热点
## 避免的话题
```

**维护**:
- 人工维护
- 每周日回顾更新

---

## Layer 2: memory-lancedb-pro

### 配置规范

```json
{
  "embedding": {
    "provider": "openai-compatible",
    "apiKey": "ollama-local",
    "model": "nomic-embed-text",
    "baseURL": "http://127.0.0.1:11434/v1",
    "dimensions": 768
  },
  "dbPath": "~/.openclaw/memory/lancedb-pro",
  "sessionStrategy": "memoryReflection",
  "autoCapture": true,
  "autoRecall": true,
  "captureAssistant": true,
  "retrieval": {
    "rerank": "cross-encoder",
    "rerankProvider": "jina",
    "rerankEndpoint": "http://127.0.0.1:8765/v1/rerank",
    "rerankApiKey": "local-rerank",
    "rerankModel": "BAAI/bge-reranker-v2-m3"
  },
  "mdMirror": {
    "enabled": true,
    "dir": "memory-md"
  }
}
```

### 目录结构

```
~/.openclaw/memory/
├── lancedb-pro/                       # 向量数据库
│   ├── memories.lance/
│   └── *.lance
└── memory-md/                         # Markdown mirror
    └── *.md
```

### Rerank Sidecar

**位置**: `~/.openclaw/workspace/services/local-rerank-sidecar/`

**配置**:
- 端口：127.0.0.1:8765
- 模型：BAAI/bge-reranker-v2-m3
- Backend：transformers（生产）/ ollama（实验）
- 自启动：launchd 服务

**健康检查**:
```bash
curl -s http://127.0.0.1:8765/health
```

---

## Layer 3: Memory Archive (NotebookLM)

### Notebook 信息

- **Notebook ID**: bb3121a4-5e95-4d32-8d9a-a85cf1e3
- **名称**: Memory Archive
- **用途**: 长期归档、深度理解、跨会话分析

### 同步策略

**周度同步**（每周日 23:00）:
- 同步 MEMORY.md
- 同步本周重要日志
- 生成周度摘要

**月度归档**（每月 1 号 01:00）:
- 归档上月所有记忆
- 生成月度摘要
- 清理本地旧文件

**深度洞察**（每月 15 号 01:00）:
- 跨会话分析
- 识别模式和趋势
- 生成改进建议

---

## Cron 任务规范

### layer2-health-check

- **时间**: 每天 02:00
- **任务**: 检查 memory-lancedb-pro 健康状态
- **模型**: minimax（降本）
- **超时**: 300 秒

### layer1-compress-check

- **时间**: 每周日 04:00
- **任务**: 压缩超过阈值的每日日志
- **模型**: minimax（降本）
- **超时**: 300 秒

### memory-archive-weekly-sync

- **时间**: 每周日 23:00
- **任务**: 同步到 Memory Archive
- **模型**: opus（高质量）
- **超时**: 600 秒

### MEMORY.md 维护

- **时间**: 每周日 22:00
- **任务**: 维护 MEMORY.md
- **模型**: opus（高质量）
- **超时**: 600 秒

---

## 数据流向

### 写入流程

```
用户对话
    ↓
memory-lancedb-pro 自动捕获 (Layer 2)
    ↓
人工提炼到 MEMORY.md (Layer 1)
    ↓
Cron 同步到 NotebookLM (Layer 3)
```

### 检索流程

```
用户查询
    ↓
优先: memory-lancedb-pro (Layer 2) - 90% 场景
    ↓
需要深度理解: NotebookLM (Layer 3)
    ↓
需要原始记录: 本地文件 (Layer 1)
```

---

## 健康指标

### Layer 1 健康指标

- ✅ MEMORY.md < 40k tokens
- ✅ 每日日志正常创建
- ✅ shared-context/ 文件完整
- ✅ 归档目录大小 < 1 GB

### Layer 2 健康指标

- ✅ 数据库大小 < 5 GB
- ✅ rerank sidecar 运行正常
- ✅ 自动捕获工作正常
- ✅ 召回测试通过

### Layer 3 健康指标

- ✅ NotebookLM CLI 可用
- ✅ Memory Archive 可访问
- ✅ 最近同步 < 7 天

### 整体健康评分

```
评分 = (Layer 1 分数 × 0.3) + (Layer 2 分数 × 0.4) + (Layer 3 分数 × 0.3)

90-100: 优秀
75-89:  良好
60-74:  一般
< 60:   需要关注
```

---

**最后更新**: 2026-03-12 15:47
**维护者**: main (小光)
