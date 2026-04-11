# Memory Cron Tasks Reference

记忆架构相关 cron 任务的通用参考。

---

## 总原则

- memory 维护类 cron 默认由 **OpenClaw 内置调度** 或 **用户手动触发**
- 每个 cron 只做单一主语的事，不做综合维护大杂烩
- 不把执行链路问题误报成记忆系统故障
- Layer 2/3 是可选的，cron 任务应根据实际安装的插件调整

---

## Layer 1

### 1. `layer1-compress-check`
- **作用**: 检查 `memory/YYYY-MM-DD.md` 是否超阈值，并执行压缩 / 归档
- **不负责**: 更新 `MEMORY.md`、更新 `shared-context/`

### 2. `MEMORY.md 维护`
- **作用**: 长期记忆晋升审查
- **动作**:
  - 回顾本周 daily logs
  - 只筛选满足门槛的长期候选项
  - 保持 `MEMORY.md` 骨架稳定
- **不负责**: Layer 2 噪音治理

---

## Layer 2（可选，需要插件）

### Layer 2A: memory-lancedb-pro

#### `layer2-health-check`
- **前提**: memory-lancedb-pro 已安装
- **作用**: 检查 recall / rerank / Layer 2 链路健康
- **检测内容**:
  - 数据库连接
  - 向量检索是否正常
  - autoRecall 是否工作

#### `memory-quality-audit`
- **前提**: memory-lancedb-pro 已安装
- **作用**: 审计记忆质量和去重
- **检测内容**:
  - 重复记忆
  - 过期记忆
  - 相关度异常

### Layer 2B: lossless-claw-enhanced

#### `lossless-health-check`
- **前提**: lossless-claw-enhanced 已安装
- **作用**: 检查 DAG 摘要和 Token 管理
- **检测内容**:
  - LCM 服务状态
  - 摘要生成是否正常

---

## Layer 3（可选，需要配置）

### `layer3-sync`（如配置了 Layer 3）
- **前提**: NotebookLM 或其他 Layer 3 方案已配置
- **作用**: 周度同步到 Memory Archive
- **检测内容**:
  - Layer 3 服务状态
  - 同步是否正常

### 注意事项
- 单次同步失败不等于 Layer 3 架构故障
- Layer 3 脚本应检测插件是否安装，不假设具体实现

---

## 插件安装检测脚本

```bash
#!/bin/bash
# 检测记忆插件安装状态

extensions_dir="$HOME/.openclaw/extensions"

echo "=== 记忆插件检测 ==="

# Layer 2A
if [ -d "$extensions_dir/memory-lancedb-pro" ]; then
    echo "✅ Layer 2A: memory-lancedb-pro 已安装"
else
    echo "❌ Layer 2A: memory-lancedb-pro 未安装"
fi

# Layer 2B
if [ -d "$extensions_dir/lossless-claw-enhanced" ]; then
    echo "✅ Layer 2B: lossless-claw-enhanced 已安装"
else
    echo "❌ Layer 2B: lossless-claw-enhanced 未安装"
fi

# Layer 3
if [ -d "$extensions_dir/notebooklm" ]; then
    echo "✅ Layer 3: NotebookLM 已配置"
elif [ -d "$extensions_dir/lossless-claw-enhanced" ]; then
    echo "⚠️  Layer 3: lossless-claw-enhanced 可用作 Layer 3"
else
    echo "❌ Layer 3: 未配置"
fi
```

---

## 触发优化流程

```
1. 用户运行 architecture-generator 的 optimize-workspace.sh
   ↓
2. 脚本检测插件安装状态
   ↓
3. 如有插件未安装，显示安装建议
   ↓
4. 用户安装插件后
   ↓
5. 用户调用 memory-architecture-manager skill
   ↓
6. skill 根据实际安装的插件优化记忆系统
```

---

**最后更新**: 2026-04-05
