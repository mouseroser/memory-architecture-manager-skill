---
name: memory-architecture-manager
description: 管理 OpenClaw 三层记忆架构（Layer 1 本地文件 + Layer 2 memory-lancedb-pro + Layer 3 NotebookLM）。支持初始化、验证、健康检查和修复。
---

# Memory Architecture Manager

管理 OpenClaw 的三层记忆架构，确保所有层级正常工作并相互配合。

## When This Skill Triggers

使用本 skill 当：
- 初始化新的 OpenClaw 实例的记忆系统
- 验证三层架构的完整性
- 生成记忆系统健康报告
- 修复架构问题
- 迁移或备份记忆系统

## Three-Layer Architecture

### Layer 1: 本地文件（底层 - 原始记录）
- **位置**: `~/.openclaw/workspace/memory/`
- **文件**:
  - `MEMORY.md` - 精华长期记忆
  - `memory/YYYY-MM-DD.md` - 每日日志
  - `shared-context/` - 跨 agent 知识
  - `intel/` - Agent 协作文件
- **维护**: 人工维护 + Cron 压缩
- **用途**: 启动时加载，人类可读

### Layer 2: memory-lancedb-pro（中层 - 快速检索）
- **位置**: `~/.openclaw/memory/lancedb-pro/`
- **技术**: 向量检索 + BM25 + Rerank
- **维护**: 自动捕获
- **用途**: 运行时快速检索（90% 场景）

### Layer 3: Memory Archive (NotebookLM)（顶层 - 深度理解）
- **位置**: NotebookLM (云端)
- **Notebook ID**: bb3121a4-5e95-4d32-8d9a-a85cf1e3
- **维护**: Cron 同步
- **用途**: 长期归档、深度理解、跨会话分析

## Required Read

执行前必读：
1. `references/architecture-spec.md` - 架构规范
2. `references/layer-mapping.md` - 层级映射关系
3. `~/.openclaw/workspace/MEMORY-ARCHITECTURE.md` - 架构说明文档

## Usage

### 初始化三层架构

```
使用 memory-architecture-manager skill 初始化三层记忆架构
```

### 验证架构完整性

```
使用 memory-architecture-manager skill 验证记忆架构
```

### 生成健康报告

```
使用 memory-architecture-manager skill 生成记忆系统健康报告
```

### 修复架构问题

```
使用 memory-architecture-manager skill 修复记忆架构问题
```

## Operations

### 1. Initialize（初始化）

**目的**: 为新的 OpenClaw 实例初始化完整的三层记忆架构

**步骤**:

#### Layer 1 初始化
1. 创建目录结构:
   ```bash
   mkdir -p ~/.openclaw/workspace/memory
   mkdir -p ~/.openclaw/workspace/memory/archive
   mkdir -p ~/.openclaw/workspace/shared-context
   mkdir -p ~/.openclaw/workspace/intel/collaboration
   ```

2. 创建核心文件:
   - `MEMORY.md` - 从模板创建
   - `memory/$(date +%Y-%m-%d)-daily.md` - 今日日志
   - `shared-context/THESIS.md` - 当前世界观
   - `shared-context/FEEDBACK-LOG.md` - 跨 agent 纠正
   - `shared-context/SIGNALS.md` - 追踪趋势
   - `MEMORY-ARCHITECTURE.md` - 架构说明

3. 创建维护脚本:
   - `scripts/layer1-compress-check.sh`
   - `scripts/layer2-health-check.sh`

#### Layer 2 初始化
1. 验证 memory-lancedb-pro 插件已安装
2. 验证配置正确:
   - `autoCapture: true`
   - `autoRecall: true`
   - `sessionStrategy: "memoryReflection"`
3. 验证 rerank sidecar 运行
4. 初始化数据库（自动）

#### Layer 3 初始化
1. 验证 NotebookLM CLI 可用
2. 验证 Memory Archive notebook 存在
3. 创建初始 source（MEMORY.md）

#### Cron 任务初始化
1. Layer 2 健康检查（每天 02:00）
2. Layer 1 压缩检查（每周日 04:00）
3. Memory Archive 周度同步（每周日 23:00）

**输出**: 初始化报告 + 架构验证结果

---

### 2. Validate（验证）

**目的**: 验证三层架构的完整性和正确性

**检查项**:

#### Layer 1 验证
- ✅ 目录结构完整
- ✅ 核心文件存在（MEMORY.md, MEMORY-ARCHITECTURE.md）
- ✅ shared-context/ 文件完整
- ✅ 维护脚本存在且可执行

#### Layer 2 验证
- ✅ memory-lancedb-pro 插件已加载
- ✅ 数据库路径存在
- ✅ rerank sidecar 运行正常
- ✅ 自动捕获工作正常
- ✅ 召回测试通过

#### Layer 3 验证
- ✅ NotebookLM CLI 可用
- ✅ Memory Archive notebook 可访问
- ✅ 最近同步时间 < 7 天

#### Cron 任务验证
- ✅ layer2-health-check 存在且启用
- ✅ layer1-compress-check 存在且启用
- ✅ memory-archive-weekly-sync 存在且启用

**输出**: 验证报告（通过/失败/警告）

---

### 3. Health Report（健康报告）

**目的**: 生成三层架构的综合健康报告

**报告内容**:

#### Layer 1 健康
- 文件数量和大小
- MEMORY.md token 数
- 最近更新时间
- 归档目录统计

#### Layer 2 健康
- 数据库大小
- 记忆条目数量
- rerank sidecar 状态
- 最近捕获时间
- 召回质量评分

#### Layer 3 健康
- Notebook source 数量
- 最近同步时间
- 同步状态

#### 整体评分
- 健康评分（0-100）
- 关键问题清单
- 改进建议

**输出**: 健康报告 markdown 文件

---

### 4. Repair（修复）

**目的**: 自动修复架构问题

**修复项**:

#### Layer 1 修复
- 创建缺失的目录
- 从模板恢复缺失的文件
- 修复脚本权限

#### Layer 2 修复
- 重启 rerank sidecar
- 重建索引（如果损坏）
- 清理过期数据

#### Layer 3 修复
- 重新认证 NotebookLM
- 重新同步 MEMORY.md
- 修复损坏的 source

#### Cron 任务修复
- 重新创建缺失的任务
- 修复任务配置
- 启用被禁用的任务

**输出**: 修复报告（已修复/无法修复）

---

## File Templates

### MEMORY.md 模板

```markdown
# MEMORY.md - 长期记忆

## ⚠️ 血泪教训（永不重犯）

（待补充）

---

## ❌ 错误示范（不要这样做）

（待补充）

---

## 核心偏好

### 沟通风格
- 简洁有力，不废话
- 默认自动执行，不反复确认

### 记忆习惯
- 遇到问题立即记录
- 踩坑即记，防止重复

---

## 配置信息

（待补充）

---

**最后更新**: {{date}}
```

### 每日日志模板

```markdown
# 每日日志 — {{date}}

## 今日重点

（待补充）

## 完成的任务

（待补充）

## 学到的经验

（待补充）

## 待办事项

### 明天
- [ ] 

### 本周
- [ ] 

---

**记录时间**: {{datetime}}
**状态**: 进行中
```

### THESIS.md 模板

```markdown
# THESIS.md - 当前世界观

## 我当前关注什么

（待补充）

---

## 我已经写了什么

（待补充）

---

## 还有哪些空白

（待补充）

---

## 下一步计划

（待补充）

---

**最后更新**: {{date}}
```

---

## Execution Flow

### Initialize Flow

```
1. 检查是否已初始化
   ├─ 已初始化 → 询问是否重新初始化
   └─ 未初始化 → 继续

2. 创建 Layer 1 结构
   ├─ 创建目录
   ├─ 创建核心文件（从模板）
   └─ 创建维护脚本

3. 验证 Layer 2
   ├─ 检查插件状态
   ├─ 检查配置
   └─ 检查 rerank sidecar

4. 验证 Layer 3
   ├─ 检查 NotebookLM CLI
   └─ 检查 Memory Archive

5. 创建 Cron 任务
   ├─ layer2-health-check
   ├─ layer1-compress-check
   └─ memory-archive-weekly-sync

6. 生成初始化报告
   └─ 推送到监控群
```

### Validate Flow

```
1. 并行验证三层
   ├─ Layer 1: 文件和目录
   ├─ Layer 2: 插件和数据库
   └─ Layer 3: NotebookLM

2. 验证 Cron 任务

3. 生成验证报告
   ├─ 通过项
   ├─ 失败项
   └─ 警告项

4. 如果有失败项
   └─ 询问是否执行修复
```

### Health Report Flow

```
1. 收集 Layer 1 数据
   ├─ 文件统计
   └─ 最近更新

2. 收集 Layer 2 数据
   ├─ 运行 layer2-health-check.sh
   └─ 解析报告

3. 收集 Layer 3 数据
   ├─ 查询 NotebookLM
   └─ 检查同步状态

4. 计算整体评分

5. 生成健康报告
   └─ 保存到 memory/health-report-YYYYMMDD.md
```

### Repair Flow

```
1. 运行验证
   └─ 识别问题

2. 按优先级修复
   ├─ P0: 关键问题（数据丢失风险）
   ├─ P1: 重要问题（功能不可用）
   └─ P2: 一般问题（性能影响）

3. 每个问题
   ├─ 尝试自动修复
   ├─ 验证修复结果
   └─ 记录修复日志

4. 生成修复报告
   ├─ 已修复
   ├─ 无法修复（需要人工）
   └─ 建议

5. 推送报告到监控群
```

---

## Examples

### 示例 1: 初始化新实例

```
使用 memory-architecture-manager skill 初始化三层记忆架构

输出:
✅ Layer 1 初始化完成
  - 创建 7 个目录
  - 创建 6 个核心文件
  - 创建 2 个维护脚本

✅ Layer 2 验证通过
  - memory-lancedb-pro 已加载
  - rerank sidecar 运行正常

✅ Layer 3 验证通过
  - NotebookLM CLI 可用
  - Memory Archive 可访问

✅ Cron 任务创建完成
  - layer2-health-check (每天 02:00)
  - layer1-compress-check (每周日 04:00)
  - memory-archive-weekly-sync (每周日 23:00)

🎉 三层记忆架构初始化完成！
```

### 示例 2: 验证架构

```
使用 memory-architecture-manager skill 验证记忆架构

输出:
✅ Layer 1: 通过 (10/10)
✅ Layer 2: 通过 (5/5)
⚠️ Layer 3: 警告 (2/3)
  - 最近同步时间: 10 天前（建议 < 7 天）

✅ Cron 任务: 通过 (3/3)

整体评分: 85/100（良好）

建议:
- 手动触发 memory-archive-weekly-sync
```

### 示例 3: 生成健康报告

```
使用 memory-architecture-manager skill 生成记忆系统健康报告

输出:
📊 记忆系统健康报告

Layer 1:
- 文件数: 45
- MEMORY.md: ~15k tokens
- 最近更新: 2 小时前
- 归档: 12 个文件

Layer 2:
- 数据库: 2.3 GB
- 记忆条目: 1,247
- 健康评分: 75/100
- 最近捕获: 5 分钟前

Layer 3:
- Sources: 8
- 最近同步: 3 天前
- 状态: 正常

整体评分: 82/100（良好）

报告已保存: memory/health-report-20260312.md
```

### 示例 4: 修复问题

```
使用 memory-architecture-manager skill 修复记忆架构问题

输出:
🔧 开始修复...

P0 问题: 无
P1 问题: 1 个
  - rerank sidecar 未运行
    ✅ 已重启: launchctl kickstart

P2 问题: 2 个
  - THESIS.md 超过 7 天未更新
    ⚠️ 需要人工更新
  - Layer 3 同步延迟
    ✅ 已触发同步任务

修复完成: 2/3
需要人工: 1/3

建议:
- 更新 shared-context/THESIS.md
```

---

## Notes

- 初始化前会检查是否已存在，避免覆盖现有数据
- 修复操作会先备份，确保安全
- 健康报告每天自动生成（通过 Cron）
- 验证可以随时运行，不会修改数据

## Version History

- v1.0 (2026-03-12): 初始版本
  - 支持初始化、验证、健康报告、修复
  - 完整的三层架构管理
