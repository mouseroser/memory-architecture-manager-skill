---
name: memory-architecture-manager
description: 管理 OpenClaw 记忆架构（Layer 1 本地文件 + Layer 2 双轨并行：memory-lancedb-pro 长期记忆 + lossless-claw-enhanced 上下文管理 + Layer 3 可选深度归档），并按当前口径维护 root / sub-agent 的 MEMORY 骨架、daily log、archive 与记忆噪音治理。
---

# Memory Architecture Manager

管理 OpenClaw 的记忆架构，确保多层配合正常，并与当前文件架构保持一致。

## 核心定位

**可选模块，按需调用。**

- memory-architecture-manager 是独立的记忆架构优化工具
- architecture-generator 检测到插件后，会提示用户是否运行本 skill
- 用户也可以单独调用本 skill 进行记忆架构优化

## 与 architecture-generator 的联动

**职责边界**:
- **architecture-generator**: 初始化 workspace 结构、验证、补全缺失文件、优化格式、修复 agent 位置
- **memory-architecture-manager**: 管理记忆架构 (Layer 1/2/3)，专注记忆内容的组织与检索

**三 Skill 联动架构**:

```
architecture-generator（主入口）
    └── optimize-workspace.sh
        ├── Step 1: 检查结构 → converge --fill
        ├── Step 1.5: 检查 agent 位置 → converge --fix-agents
        ├── Step 2-4: 检查 Layer 1/2/agent 配置
        ├── Step 4.5: 调用 reorganize-agent-content.sh
        └── Step 5: 检测插件 → 提示运行 memory-architecture-manager
```

**实际工作流**:
- 用户先运行 architecture-generator 的 optimize-workspace.sh
- 脚本检测插件安装状态，给出安装建议
- 用户安装插件后，optimize-workspace.sh 提示是否运行 memory-architecture-manager
- 用户确认后，调用本 skill 的 optimize-memory-architecture.sh

**被 architecture-generator 调用**:

```bash
# optimize-workspace.sh 会调用：
bash ~/.openclaw/skills/memory-architecture-manager/scripts/optimize-memory-architecture.sh \
  <workspace-dir>
```

**共享文档**:
- 读取 `workspace/shared-context/AGENT-FILE-ARCHITECTURE.md`
- 维护 `workspace/MEMORY.md` 和 `workspace/MEMORY-ARCHITECTURE.md`

## 记忆架构（双轨并行）

```
┌─────────────────────────────────────────────────────┐
│ Layer 1: 本地文件（人工维护 + 启动加载）              │
│ - workspace/MEMORY.md                               │
│ - workspace/memory/YYYY-MM-DD.md                    │
│ - workspace/shared-context/*.md                     │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ Layer 2: 自动记忆系统（运行时，双轨并行）             │
│                                                     │
│ ┌─────────────────────┐  ┌─────────────────────┐  │
│ │ memory-lancedb-pro  │  │ lossless-claw-      │  │
│ │ （长期记忆）         │  │ enhanced            │  │
│ │                     │  │ （上下文管理）       │  │
│ │ - 向量检索          │  │ - DAG 摘要          │  │
│ │ - 自动捕捉          │  │ - Token 管理        │  │
│ │ - 智能遗忘          │  │ - CJK 友好          │  │
│ │ - 跨会话记忆        │  │ - 当前会话上下文    │  │
│ └─────────────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ Layer 3: 深度归档（可选，高级用户）                  │
│ - NotebookLM（高级用户，按需配置）                     │
│ - 其他云端归档方案                                   │
└─────────────────────────────────────────────────────┘
```

### 层级定义

| 层级 | 组件 | 用途 | 必需性 |
|------|------|------|--------|
| **Layer 1** | 本地文件 | 启动加载、人工维护 | ✅ 必需 |
| **Layer 2A** | memory-lancedb-pro | 长期记忆、跨会话检索 | ⭐⭐⭐⭐⭐ 强烈推荐 |
| **Layer 2B** | lossless-claw-enhanced | 上下文管理、DAG 摘要 | ⭐⭐⭐⭐⭐ 强烈推荐 |
| **Layer 3** | NotebookLM / 其他 | 深度归档、研究分析 | ⭐⭐⭐ 可选（高级） |

### 安装组合

| 组合 | Layer 2A | Layer 2B | 适用场景 | 推荐度 |
|------|---------|---------|---------|--------|
| **完整配置** | ✅ | ✅ | 生产环境（推荐） | ⭐⭐⭐⭐⭐ |
| **记忆优先** | ✅ | ❌ | 重视长期记忆，不在意上下文管理 | ⭐⭐⭐⭐ |
| **上下文优先** | ❌ | ✅ | 重视上下文管理，不需要跨会话记忆 | ⭐⭐⭐ |
| **极简配置** | ❌ | ❌ | 只用内置功能 | ⭐⭐ |

### 插件安装

**memory-lancedb-pro**（长期记忆）:
- GitHub: https://github.com/CortexReach/memory-lancedb-pro
- 安装: `openclaw plugins install memory-lancedb-pro@beta`
- 功能: 向量检索、自动捕捉、智能遗忘、跨会话记忆
- 工具: memory_store, memory_recall, memory_forget 等

**lossless-claw-enhanced**（上下文管理）:
- GitHub: https://github.com/win4r/lossless-claw-enhanced
- 安装: `openclaw plugins install --link ./lossless-claw-enhanced`
- 功能: DAG-based 摘要、Token 管理、CJK 友好
- 工具: lcm_grep, lcm_expand, lcm_describe 等

## 当前口径

### Layer 1
- root `MEMORY.md`：系统级长期护栏
- sub-agent `MEMORY.md`：agent-specific 长期伤疤
- `memory/YYYY-MM-DD.md`：当天账本与晋升池
- `shared-context/`：跨 agent 知识
- `intel/`：协作与情报层

### Layer 2A: memory-lancedb-pro
- 长期记忆存储（LanceDB 向量数据库）
- 自动捕获 / 自动召回
- 混合检索（向量 + BM25）
- 智能遗忘（Weibull 衰减）
- 噪音治理优先：清理 system envelope、WhatsApp connect/disconnect、heartbeat ack 等

### Layer 2B: lossless-claw-enhanced
- 上下文管理（替代内置滑动窗口）
- DAG-based 摘要（保留所有消息）
- 保持活跃上下文在 token 限制内
- CJK 友好的 token 估算

### Layer 3
- **可选配置**（按需选择）
- NotebookLM：深度归档（高级用户，按需配置）
- 长期归档 / 深度理解 / 跨会话分析

## Required Read
1. `references/architecture-spec.md`
2. `references/layer-mapping.md`
3. `references/cron-tasks.md`
4. `~/.openclaw/workspace/MEMORY.md`
5. `~/.openclaw/workspace/MEMORY-ARCHITECTURE.md`
6. `~/.openclaw/workspace/shared-context/AGENT-FILE-ARCHITECTURE.md`（如存在）

## Layer 1 规则

### MEMORY.md 统一骨架
main 与 sub-agent 的 `MEMORY.md` 统一骨架：
1. 血泪教训
2. 错误示范 / 反模式
3. 长期稳定规则
4. 长期偏好（可选）

### 写入门槛
至少满足以下 3 条才进 MEMORY.md：
- 高代价
- 可复发
- 已验证
- 长期有效
- 不写进去以后大概率还会再犯

### 不要混装
不要把这些写进 MEMORY.md：
- 执行手册
- 路径说明
- 模板 / contract
- 工作目录
- 流程步骤

## Layer 2 噪音治理

### 优先清理的噪音类型
1. System envelope（gateway restart、plugin loaded）
2. WhatsApp connect/disconnect
3. Heartbeat ack（HEARTBEAT_OK）
4. 空 announce（无实质内容）
5. 重复的低价值记忆

### 清理策略
- 使用 `compress-memory.sh` 定期清理
- 使用 `memory-quality-audit.sh` 审计记忆质量
- 使用 `memory_compact` 工具合并重复记忆

## 记忆维护任务

### 定期任务（建议通过 cron 或手动触发）

| 任务 | 频率 | 脚本 |
|------|------|------|
| Layer 2 健康检查 | 每日 | `layer2-health-check.sh` |
| 记忆质量审计 | 每周 | `memory-quality-audit.sh` |
| 记忆压缩 | 每周 | `compress-memory.sh` |
| 每日记忆报告 | 每日 | `daily-memory-report.sh` |
| Layer 3 月度归档 | 每月 | `layer3-monthly-archive.sh`（如已配置） |
| 高优先级记忆同步 | 按需 | `sync-high-priority-memories.sh`（如已配置） |

### 脚本位置
所有脚本位于 `~/.openclaw/skills/memory-architecture-manager/scripts/`

## 工具映射

| 操作 | Layer 1 | Layer 2A | Layer 2B | Layer 3 |
|------|---------|----------|----------|---------|
| **读取** | read 工具 | memory_recall | lcm_grep | NotebookLM |
| **写入** | write/edit | memory_store | - | NotebookLM |
| **删除** | exec rm | memory_forget | - | NotebookLM |
| **搜索** | exec grep | memory_recall | lcm_grep | NotebookLM query |
| **展开** | - | - | lcm_expand | - |
| **统计** | exec wc | memory_stats | lcm_describe | - |

## 使用场景

### 场景 1: 初始化记忆架构
新建 workspace 后，初始化记忆架构。

### 场景 2: 插件安装后优化
安装 Layer 2A/2B 插件后，优化记忆架构。

### 场景 3: 定期健康检查
定期检查记忆系统健康状态。

### 场景 4: 记忆质量审计
审计记忆质量，清理低质量记忆。

### 场景 5: 月度归档
每月归档记忆到 Layer 3（如已配置）。

## Notes

- Layer 2A 和 Layer 2B 是并行的两个插件，不是层级关系
- 强烈推荐生产环境两个都安装
- Layer 3 是可选配置，按需选择
- 记忆维护任务建议通过 cron 定期执行
- 噪音治理是持续过程，需要定期审计和清理
