# Memory Cron Tasks Reference

三层记忆架构的自动化任务配置参考。

---

## 📋 Memory 相关 Cron 任务

### Layer 1: 本地文件

#### 1. layer1-compress-check
**时间**: 每周日 04:00  
**脚本**: `~/.openclaw/scripts/layer1-compress-check.sh`  
**功能**: 检查 memory/YYYY-MM-DD.md 文件大小，识别超过 40k tokens 的文件

**创建命令**:
```bash
openclaw cron add \
  --name "layer1-compress-check" \
  --schedule "0 4 * * 0" \
  --agent main \
  --model minimax/MiniMax-M2.5 \
  --thinking low \
  --task "执行 Layer 1 压缩检查任务..."
```

#### 2. MEMORY.md 维护
**时间**: 每周日 22:00  
**功能**: 回顾本周日志，提取重要内容到 MEMORY.md

---

### Layer 2: memory-lancedb-pro

#### 1. layer2-health-check
**时间**: 每天 02:00  
**脚本**: `~/.openclaw/scripts/layer2-health-check.sh`  
**功能**: 检查 memory-lancedb-pro 插件状态、向量数据库健康、rerank 服务状态

**创建命令**:
```bash
openclaw cron add \
  --name "layer2-health-check" \
  --schedule "0 2 * * *" \
  --agent main \
  --model minimax/MiniMax-M2.5 \
  --thinking low \
  --task "执行 Layer 2 健康检查任务..."
```

#### 2. memory-quality-audit
**时间**: 每天 03:00  
**功能**: 记忆质量审计

#### 3. sync-high-priority-memories
**时间**: 每天 04:00  
**功能**: 同步高优先级记忆

#### 4. daily-memory-report
**时间**: 每天 05:00  
**功能**: 生成每日记忆报告

---

### Layer 3: Memory Archive (NotebookLM)

#### 1. memory-archive-weekly-sync
**时间**: 每周日 23:00  
**功能**: 周度同步到 Memory Archive

#### 2. layer3-monthly-archive
**时间**: 每月 1 号 01:00  
**脚本**: `~/.openclaw/scripts/layer3-monthly-archive.sh`  
**功能**: 收集上月的 MEMORY.md 和重要日志，上传到 Memory Archive

**创建命令**:
```bash
openclaw cron add \
  --name "layer3-monthly-archive" \
  --schedule "0 1 1 * *" \
  --agent main \
  --model anthropic/claude-opus-4-6 \
  --thinking medium \
  --task "执行 Layer 3 月度归档任务..."
```

#### 3. layer3-deep-insights
**时间**: 每月 15 号 01:00  
**脚本**: `~/.openclaw/scripts/layer3-deep-insights.sh`  
**功能**: 查询 Memory Archive，生成跨会话分析、识别模式和趋势、生成改进建议

**创建命令**:
```bash
openclaw cron add \
  --name "layer3-deep-insights" \
  --schedule "0 1 15 * *" \
  --agent main \
  --model anthropic/claude-opus-4-6 \
  --thinking high \
  --task "执行 Layer 3 深度洞察任务..."
```

---

## 📊 完整时间表

| 时间 | 任务 | Layer | 频率 |
|------|------|-------|------|
| 02:00 | layer2-health-check | Layer 2 | 每天 |
| 03:00 | memory-quality-audit | All | 每天 |
| 04:00 | sync-high-priority-memories | Layer 2 | 每天 |
| 04:00 | layer1-compress-check | Layer 1 | 每周日 |
| 05:00 | daily-memory-report | All | 每天 |
| 22:00 | MEMORY.md 维护 | Layer 1 | 每周日 |
| 23:00 | memory-archive-weekly-sync | Layer 3 | 每周日 |
| 01:00 (1号) | layer3-monthly-archive | Layer 3 | 每月 |
| 01:00 (15号) | layer3-deep-insights | Layer 3 | 每月 |

---

## 🔧 管理命令

### 查看所有 Cron 任务
```bash
openclaw cron list
```

### 查看特定任务
```bash
openclaw cron runs <job-id>
```

### 手动触发任务
```bash
openclaw cron trigger <job-id>
```

### 禁用/启用任务
```bash
openclaw cron update <job-id> --enabled false
openclaw cron update <job-id> --enabled true
```

### 删除任务
```bash
openclaw cron remove <job-id>
```

---

**维护者**: main (小光)  
**最后更新**: 2026-03-12
