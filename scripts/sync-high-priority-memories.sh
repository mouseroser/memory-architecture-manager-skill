#!/bin/bash
# 高优先级记忆同步脚本
# 自动查询 importance >= 0.9 的记忆并同步到 Layer 3

set -euo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
TMP_DIR="$WORKSPACE/.tmp"
TIMESTAMP_HUMAN=$(date +"%Y-%m-%d %H:%M:%S")
TIMESTAMP_FILE=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$WORKSPACE/memory/sync-high-priority-$TIMESTAMP_FILE.log"
MEMORY_DATA="$TMP_DIR/high-priority-memories-$TIMESTAMP_FILE.json"
SYNC_DOC="$TMP_DIR/high-priority-sync-$TIMESTAMP_FILE.md"

mkdir -p "$TMP_DIR" "$(dirname "$LOG_FILE")"

echo "[$TIMESTAMP_HUMAN] 开始高优先级记忆同步" | tee "$LOG_FILE"
echo "[$TIMESTAMP_HUMAN] 查询 importance >= 0.9 的记忆..." | tee -a "$LOG_FILE"

# 检测 Layer 3 配置
LAYER3_TYPE="none"
LAYER3_AVAILABLE=false

if [ -d "$HOME/.openclaw/extensions/notebooklm" ]; then
  LAYER3_TYPE="notebooklm"
  LAYER3_AVAILABLE=true
elif [ -d "$HOME/.openclaw/extensions/lossless-claw-enhanced" ]; then
  LAYER3_TYPE="lossless-claw-enhanced"
  LAYER3_AVAILABLE=true
fi

echo "[$TIMESTAMP_HUMAN] Layer 3 类型: $LAYER3_TYPE" | tee -a "$LOG_FILE"

# 使用 openclaw memory list 命令（如果可用）
if command -v openclaw >/dev/null 2>&1; then
  RAW_OUTPUT=$(openclaw memory list --json --limit 500 2>/dev/null || true)
  
  if [ -n "$RAW_OUTPUT" ]; then
    # 尝试提取 JSON
    JSON_OUTPUT=$(printf '%s\n' "$RAW_OUTPUT" | sed -n '/^\[$/,$p' || true)
    
    if [ -n "$JSON_OUTPUT" ]; then
      printf '%s\n' "$JSON_OUTPUT" | jq '[.[] | select((.importance // 0) >= 0.9)]' > "$MEMORY_DATA" 2>/dev/null || true
    fi
  fi
fi

# 如果 JSON 提取失败，生成空文件
if [ ! -f "$MEMORY_DATA" ]; then
  echo "[]" > "$MEMORY_DATA"
fi

MEMORY_COUNT=$(jq 'length' "$MEMORY_DATA" 2>/dev/null || echo "0")

echo "[$TIMESTAMP_HUMAN] 找到 $MEMORY_COUNT 条高优先级记忆" | tee -a "$LOG_FILE"

if [ "$MEMORY_COUNT" -eq 0 ] || [ "$MEMORY_COUNT" = "0" ]; then
    echo "[$TIMESTAMP_HUMAN] ✅ 当前没有需要同步的高优先级记忆" | tee -a "$LOG_FILE"
    rm -f "$MEMORY_DATA"
    exit 0
fi

# 生成同步文档
cat > "$SYNC_DOC" <<EOF
# 高优先级记忆同步 - $TIMESTAMP_HUMAN

> 自动同步 importance >= 0.9 的记忆

## 同步统计

- 记忆数量: $MEMORY_COUNT
- 同步时间: $TIMESTAMP_HUMAN
- 最小重要性: 0.9
- Layer 3 类型: $LAYER3_TYPE

## 记忆列表

EOF

jq -r '.[] | "### \(.text)\n\n- **重要性**: \(.importance // 0)\n- **分类**: \(.category // "unknown")\n- **作用域**: \(.scope // "default")\n- **时间戳**: \(.timestamp // "unknown")\n- **ID**: \(.id)\n\n---\n"' "$MEMORY_DATA" >> "$SYNC_DOC"

echo "[$TIMESTAMP_HUMAN] 已生成同步文档: $SYNC_DOC" | tee -a "$LOG_FILE"

# 同步到 Layer 3（如果可用）
if [ "$LAYER3_AVAILABLE" = true ]; then
  if [ "$LAYER3_TYPE" = "notebooklm" ]; then
    echo "[$TIMESTAMP_HUMAN] 同步到 NotebookLM..." | tee -a "$LOG_FILE"
    
    # 检查 NotebookLM CLI
    if ! command -v notebooklm >/dev/null 2>&1; then
      echo "[$TIMESTAMP_HUMAN] ⚠️ NotebookLM CLI 不可用，跳过同步" | tee -a "$LOG_FILE"
      echo "[$TIMESTAMP_HUMAN] 💡 同步文档已保存在: $SYNC_DOC" | tee -a "$LOG_FILE"
    else
      # 读取 NotebookLM 配置
      NOTEBOOKS_CONFIG="$HOME/.openclaw/skills/notebooklm/config/notebooks.json"
      NOTEBOOK_NAME="memory-archive"
      NOTEBOOK_ID=""
      
      if [ -f "$NOTEBOOKS_CONFIG" ] && command -v python3 >/dev/null 2>&1; then
        NOTEBOOK_ID=$(python3 - "$NOTEBOOKS_CONFIG" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(data.get('notebooks', {}).get('memory-archive', {}).get('id', ''))
except Exception:
    print('')
PY
)
      fi
      
      if [ -n "$NOTEBOOK_ID" ]; then
        if notebooklm source add -n "$NOTEBOOK_ID" --title "high-priority-sync-$TIMESTAMP_FILE" "$SYNC_DOC" >/dev/null 2>&1; then
          echo "[$TIMESTAMP_HUMAN] ✅ 高优先级记忆同步完成: NotebookLM" | tee -a "$LOG_FILE"
        else
          echo "[$TIMESTAMP_HUMAN] ⚠️ NotebookLM 上传失败" | tee -a "$LOG_FILE"
          echo "[$TIMESTAMP_HUMAN] 💡 同步文档已保存在: $SYNC_DOC" | tee -a "$LOG_FILE"
        fi
      else
        echo "[$TIMESTAMP_HUMAN] ⚠️ 无法获取 Notebook ID，跳过同步" | tee -a "$LOG_FILE"
        echo "[$TIMESTAMP_HUMAN] 💡 同步文档已保存在: $SYNC_DOC" | tee -a "$LOG_FILE"
      fi
    fi
    
  elif [ "$LAYER3_TYPE" = "lossless-claw-enhanced" ]; then
    echo "[$TIMESTAMP_HUMAN] ✅ 使用 lossless-claw-enhanced（自动 DAG 归档）" | tee -a "$LOG_FILE"
    echo "[$TIMESTAMP_HUMAN] 💡 同步文档已保存在: $SYNC_DOC" | tee -a "$LOG_FILE"
  fi
else
  echo "[$TIMESTAMP_HUMAN] ℹ️ Layer 3 未配置，跳过同步" | tee -a "$LOG_FILE"
  echo "[$TIMESTAMP_HUMAN] 💡 同步文档已保存在: $SYNC_DOC" | tee -a "$LOG_FILE"
fi

echo ""
echo "📊 同步完成！"
echo "  - 记忆数量: $MEMORY_COUNT"
echo "  - Layer 3 类型: $LAYER3_TYPE"
echo "  - 日志: $LOG_FILE"
echo "  - 同步文档: $SYNC_DOC"
