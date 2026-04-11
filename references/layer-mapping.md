# Layer Mapping Reference

记忆架构的完整映射关系（双轨并行）。

---

## 快速参考表

| 维度 | Layer 1 | Layer 2A | Layer 2B | Layer 3 |
|------|---------|----------|----------|---------|
| **名称** | 本地文件 | memory-lancedb-pro | lossless-claw-enhanced | Deep Archive |
| **位置** | `workspace/memory/` | `~/.openclaw/memory/lancedb-pro/` | 上下文管理 | 可选配置 |
| **类型** | 文件系统 | 向量数据库 | LCM 插件 | 云端归档 |
| **维护** | 人工 + Cron | 自动 | 自动 | Cron |
| **用途** | 启动加载 | 长期记忆 | 上下文管理 | 深度分析 |
| **频率** | 每周 | 实时 | 实时 | 每月 |
| **容量** | < 100 MB | < 5 GB | 无限制 | 无限 |
| **检索速度** | 慢（文件读取） | 快（向量检索） | 快（DAG 遍历） | 中（API 调用） |
| **适用场景** | 启动、人工查看 | 跨会话记忆 | 当前会话上下文 | 深度研究 |

---

## 层级定义（双轨并行）

### Layer 1: 本地文件（必需）
- **位置**: `workspace/memory/`
- **维护**: 人工 + Cron
- **用途**: 启动加载、人工维护
- **必需性**: ✅ 必需

### Layer 2: 自动记忆系统（双轨并行）

#### Layer 2A: memory-lancedb-pro（长期记忆）
- **功能**: 向量检索、自动捕捉、智能遗忘、跨会话记忆
- **GitHub**: https://github.com/CortexReach/memory-lancedb-pro
- **安装**: `openclaw plugins install memory-lancedb-pro@beta`
- **推荐度**: ⭐⭐⭐⭐⭐ 强烈推荐
- **工具**: memory_store, memory_recall, memory_forget, memory_stats 等

#### Layer 2B: lossless-claw-enhanced（上下文管理）
- **功能**: DAG-based 摘要、Token 管理、CJK 友好
- **GitHub**: https://github.com/win4r/lossless-claw-enhanced
- **安装**: `openclaw plugins install lossless-claw`
- **启用**: `openclaw plugins enable lossless-claw`
- **推荐度**: ⭐⭐⭐⭐⭐ 强烈推荐
- **工具**: lcm_grep, lcm_expand, lcm_describe 等

### Layer 3: 深度归档（可选，高级用户）
- **NotebookLM**: 云端，支持生成洞察（高级用户，按需配置）
- **其他云端归档方案**
- **推荐度**: ⭐⭐⭐ 可选（高级）

---

## 安装组合

| 组合 | Layer 2A | Layer 2B | 适用场景 | 推荐度 |
|------|---------|---------|---------|--------|
| **完整配置** | ✅ | ✅ | 生产环境（推荐） | ⭐⭐⭐⭐⭐ |
| **记忆优先** | ✅ | ❌ | 重视长期记忆，不在意上下文管理 | ⭐⭐⭐⭐ |
| **上下文优先** | ❌ | ✅ | 重视上下文管理，不需要跨会话记忆 | ⭐⭐⭐ |
| **极简配置** | ❌ | ❌ | 只用内置功能 | ⭐⭐ |

---

## 详细映射

### 文件路径映射

| 文件类型 | Layer 1 | Layer 2A | Layer 2B | Layer 3 |
|----------|---------|----------|----------|---------|
| **精华记忆** | `MEMORY.md` | 自动捕获 | - | 周度同步 |
| **每日日志** | `memory/YYYY-MM-DD.md` | 自动捕获 | - | 周度同步 |
| **跨 agent 知识** | `shared-context/*.md` | 不参与 | 不参与 | 不参与 |
| **Agent 协作** | `intel/*.md` | 不参与 | 不参与 | 不参与 |
| **向量数据库** | - | `lancedb-pro/` | - | - |
| **Markdown mirror** | - | `memory-md/` | - | - |
| **DAG 摘要** | - | - | 会话数据库 | - |
| **云端归档** | - | - | - | 可选配置 |

---

### 数据流向映射

#### 写入流向

```
用户对话
    ↓
[Layer 2A] memory-lancedb-pro 自动捕获（长期记忆）
[Layer 2B] lossless-claw-enhanced 自动摘要（上下文管理）
    ↓
[Layer 1] 人工提炼到 MEMORY.md
    ↓
[Layer 3] Cron 同步到深度归档（可选）
```

#### 检索流向

```
用户查询
    ↓
[Layer 2A] memory_recall（长期记忆，90% 场景）
    ├─ 命中 → 返回结果
    └─ 未命中 ↓
[Layer 3] 深度归档查询（如已配置）
    ├─ 命中 → 返回结果
    └─ 未命中 ↓
[Layer 1] 直接读取文件（原始记录）
```

```
当前会话上下文
    ↓
[Layer 2B] lossless-claw-enhanced（DAG 摘要）
    ├─ lcm_grep（搜索历史消息）
    ├─ lcm_expand（展开摘要）
    └─ lcm_describe（查看摘要详情）
```

---

### 维护任务映射

| 任务 | Layer 1 | Layer 2A | Layer 2B | Layer 3 |
|------|---------|----------|----------|---------|
| **每日** | - | 健康检查（02:00）<br>质量审计（03:00） | 自动压缩 | - |
| **每周** | 压缩检查（周日 04:00）<br>MEMORY.md 维护（周日 22:00） | - | - | 周度同步（周日 23:00） |
| **每月** | - | - | - | 月度归档（1 号）<br>深度洞察（15 号） |

---

### 工具映射

| 操作 | Layer 1 | Layer 2A | Layer 2B | Layer 3 |
|------|---------|----------|----------|---------|
| **读取** | `read` 工具 | `memory_recall` | `lcm_grep` | NotebookLM CLI |
| **写入** | `write` / `edit` 工具 | `memory_store` | - | NotebookLM CLI |
| **删除** | `exec rm` | `memory_forget` | - | NotebookLM CLI |
| **搜索** | `exec grep` | `memory_recall` | `lcm_grep` | NotebookLM query |
| **展开** | - | - | `lcm_expand` | - |
| **描述** | - | `memory_stats` | `lcm_describe` | - |
| **统计** | `exec wc` | `memory_stats` | - | NotebookLM CLI |

---

### 性能映射

| 指标 | Layer 1 | Layer 2A | Layer 2B | Layer 3 |
|------|---------|----------|----------|---------|
| **容量** | < 100 MB | < 5 GB | 无限制 | 无限 |
| **检索延迟** | 100-500ms | 50-200ms | 10-100ms | 500-2000ms |
| **写入延迟** | 1-10ms | 10-50ms | 1-5ms | 1000-5000ms |
| **并发支持** | 低 | 高 | 高 | 中 |
| **覆盖率** | 10% | 90% | 100% | 5% |

> **覆盖率说明**:
> - Layer 1: 人工精选的 10% 核心记忆
> - Layer 2A: 自动捕获的 90% 日常记忆
> - Layer 2B: 100% 会话上下文（DAG 摘要）
> - Layer 3: 5% 深度归档（长期研究）

---

### 安全与隐私映射

| 维度 | Layer 1 | Layer 2A | Layer 2B | Layer 3 |
|------|---------|----------|----------|---------|
| **数据位置** | 本地 | 本地 | 本地 | 云端（可选） |
| **隐私级别** | 高 | 高 | 高 | 中 |
| **访问控制** | 文件系统 | 插件配置 | 插件配置 | API 认证 |
| **备份** | 手动 | 自动 | 自动 | 云端 |
| **恢复** | 文件恢复 | 数据库恢复 | 会话恢复 | 云端恢复 |

---

### 故障恢复映射

| 故障场景 | Layer 1 | Layer 2A | Layer 2B | Layer 3 |
|----------|---------|----------|----------|---------|
| **Layer 2A 不可用** | 正常 | - | 正常 | 正常 |
| **Layer 2B 不可用** | 正常 | 正常 | - | 正常 |
| **Layer 3 不可用** | 正常 | 正常 | 正常 | - |
| **全部不可用** | 正常（降级到文件） | - | - | - |

> **降级策略**:
> - Layer 2A 不可用 → 降级到 Layer 1（手动读取文件）
> - Layer 2B 不可用 → 降级到内置滑动窗口
> - Layer 3 不可用 → 不影响日常使用

---

## 使用建议

### 新用户
1. 先安装 Layer 2A（memory-lancedb-pro）— 长期记忆最重要
2. 再安装 Layer 2B（lossless-claw-enhanced）— 上下文管理提升体验
3. Layer 3 可选 — 高级用户才需要

### 生产环境
- ✅ Layer 1（必需）
- ✅ Layer 2A（强烈推荐）
- ✅ Layer 2B（强烈推荐）
- ⭐ Layer 3（可选，高级用户）

### 极简用户
- ✅ Layer 1（必需）
- ❌ Layer 2A（可选）
- ❌ Layer 2B（可选）
- ❌ Layer 3（不需要）

---

**最后更新**: 2026-04-05
**版本**: 2.0（双轨并行架构）
