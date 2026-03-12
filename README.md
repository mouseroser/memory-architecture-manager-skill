# Memory Architecture Manager

管理 OpenClaw 三层记忆架构的完整 skill。

## 快速开始

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

---

## 三层架构概览

### Layer 1: 本地文件（人工维护）
- **位置**: `~/.openclaw/workspace/memory/`
- **用途**: 启动时加载，人类可读
- **维护**: 人工 + Cron（每周）

### Layer 2: memory-lancedb-pro（自动捕获）
- **位置**: `~/.openclaw/memory/lancedb-pro/`
- **用途**: 运行时快速检索（90% 场景）
- **维护**: 自动捕获 + Cron（每天）

### Layer 3: Memory Archive (NotebookLM)（深度理解）
- **位置**: NotebookLM (云端)
- **用途**: 长期归档、深度洞察
- **维护**: Cron（每周/每月）

---

## 文件结构

```
memory-architecture-manager/
├── SKILL.md                              # Skill 主文档
├── README.md                             # 本文件
└── references/
    ├── architecture-spec.md              # 架构规范
    └── layer-mapping.md                  # 层级映射关系
```

---

## 支持的操作

### 1. Initialize（初始化）
为新的 OpenClaw 实例初始化完整的三层记忆架构。

**包含**:
- ✅ 创建 Layer 1 目录结构和核心文件
- ✅ 验证 Layer 2 插件和配置
- ✅ 验证 Layer 3 NotebookLM 连接
- ✅ 创建维护脚本
- ✅ 创建 Cron 任务

### 2. Validate（验证）
验证三层架构的完整性和正确性。

**检查项**:
- ✅ Layer 1: 文件和目录完整性
- ✅ Layer 2: 插件状态和数据库健康
- ✅ Layer 3: NotebookLM 连接和同步状态
- ✅ Cron 任务配置

### 3. Health Report（健康报告）
生成三层架构的综合健康报告。

**报告内容**:
- ✅ 各层级健康状态
- ✅ 整体健康评分（0-100）
- ✅ 关键问题清单
- ✅ 改进建议

### 4. Repair（修复）
自动修复架构问题。

**修复项**:
- ✅ 创建缺失的目录和文件
- ✅ 修复脚本权限
- ✅ 重启服务
- ✅ 重建索引
- ✅ 重新创建 Cron 任务

---

## 使用场景

### 场景 1: 新实例初始化
当你设置新的 OpenClaw 实例时，使用本 skill 一键初始化完整的记忆系统。

### 场景 2: 定期检查
每周或每月运行验证，确保三层架构正常工作。

### 场景 3: 故障排查
当记忆系统出现问题时，使用健康报告诊断问题，然后使用修复功能自动修复。

### 场景 4: 迁移和备份
在迁移到新机器或备份时，使用本 skill 确保架构完整。

---

## 核心优势

### 1. 一键初始化
- ✅ 无需手动创建目录和文件
- ✅ 自动配置 Cron 任务
- ✅ 验证所有依赖

### 2. 自动验证
- ✅ 定期检查架构完整性
- ✅ 早期发现问题
- ✅ 防止数据丢失

### 3. 智能修复
- ✅ 自动修复常见问题
- ✅ 优先级排序（P0/P1/P2）
- ✅ 详细的修复报告

### 4. 健康监控
- ✅ 综合健康评分
- ✅ 各层级详细指标
- ✅ 改进建议

---

## 维护计划

### 每天
- ✅ Layer 2 健康检查（02:00）
- ✅ Layer 2 质量审计（03:00）

### 每周
- ✅ Layer 1 压缩检查（周日 04:00）
- ✅ MEMORY.md 维护（周日 22:00）
- ✅ Layer 3 周度同步（周日 23:00）

### 每月
- ⚠️ Layer 3 月度归档（1 号 01:00）- Phase 2
- ⚠️ Layer 3 深度洞察（15 号 01:00）- Phase 2

---

## 示例输出

### 初始化输出

```
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

### 验证输出

```
✅ Layer 1: 通过 (10/10)
✅ Layer 2: 通过 (5/5)
⚠️ Layer 3: 警告 (2/3)
  - 最近同步时间: 10 天前（建议 < 7 天）

✅ Cron 任务: 通过 (3/3)

整体评分: 85/100（良好）

建议:
- 手动触发 memory-archive-weekly-sync
```

### 健康报告输出

```
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

---

## 版本历史

- v1.0 (2026-03-12): 初始版本
  - 支持初始化、验证、健康报告、修复
  - 完整的三层架构管理
  - 自动化维护任务

---

**创建时间**: 2026-03-12 15:53
**维护者**: main (小光)
