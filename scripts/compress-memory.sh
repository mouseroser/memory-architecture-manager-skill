#!/bin/bash
# Memory Compression Script
# 清理 memory-lancedb-pro 向量数据库中的旧记忆和重复记忆
#
# 用法:
#   compress-memory.sh [agent_id] [dry-run]
#   compress-memory.sh main true    # 只看不删
#   compress-memory.sh main false   # 实际清理
#
# 功能:
#   1. 检测 Layer 2A (memory-lancedb-pro) 是否安装
#   2. 导出所有记忆
#   3. 找出超过 90 天且 importance < 0.5 的低价值旧记忆
#   4. 找出完全重复的记忆
#   5. 归档后从 lancedb-pro 中删除

set -e

AGENT_ID="${1:-main}"
DRY_RUN="${2:-true}"
RETENTION_DAYS="${3:-90}"
MIN_IMPORTANCE="${4:-0.5}"

ARCHIVE_DIR="${HOME}/.openclaw/workspace/memory/archive"
TEMP_FILE=$(mktemp)

cleanup() {
  rm -f "$TEMP_FILE"
}
trap cleanup EXIT

echo "=== 记忆压缩 agent:${AGENT_ID} ==="
echo "模拟运行: ${DRY_RUN}"
echo "保留天数: ${RETENTION_DAYS} 天"
echo "最低重要性: ${MIN_IMPORTANCE}"
echo ""

# Step 0: 检测 Layer 2A (memory-lancedb-pro)
echo "🔍 检查 Layer 2A (memory-lancedb-pro)..."
LAYER2A_AVAILABLE=false

if [ -d "$HOME/.openclaw/extensions/memory-lancedb-pro" ]; then
  LAYER2A_AVAILABLE=true
  echo "✅ memory-lancedb-pro 已安装"
else
  echo "❌ memory-lancedb-pro 未安装"
  echo ""
  echo "💡 安装命令: openclaw plugins install memory-lancedb-pro@beta"
  echo "   GitHub: https://github.com/CortexReach/memory-lancedb-pro"
  exit 1
fi
echo ""

# Step 1: 当前状态
echo "📊 当前记忆统计:"
if command -v openclaw >/dev/null 2>&1; then
  openclaw memory stats --scope "agent:${AGENT_ID}" 2>&1 | grep -v "plugin" || true
else
  echo "⚠️ openclaw 命令不可用"
fi
echo ""

# Step 2: 导出所有记忆
echo "📤 导出记忆..."
if ! command -v openclaw >/dev/null 2>&1; then
  echo "❌ openclaw 命令不可用"
  exit 1
fi

# 使用 openclaw memory list 导出
RAW_OUTPUT=$(openclaw memory list --json --scope "agent:${AGENT_ID}" --limit 10000 2>/dev/null || true)

if [ -z "$RAW_OUTPUT" ]; then
    echo "❌ 无法导出记忆"
    exit 1
fi

# 提取 JSON
JSON_OUTPUT=$(printf '%s\n' "$RAW_OUTPUT" | sed -n '/^\[$/,$p' || true)

if [ -z "$JSON_OUTPUT" ]; then
    echo "❌ 无法提取 JSON 输出"
    exit 1
fi

echo "$JSON_OUTPUT" > "$TEMP_FILE"
TOTAL_COUNT=$(jq 'length' "$TEMP_FILE" 2>/dev/null || echo "0")
echo "总记忆数: ${TOTAL_COUNT}"
echo ""

if [ "$TOTAL_COUNT" = "0" ] || [ "$TOTAL_COUNT" -eq 0 ]; then
    echo "✅ 没有记忆需要处理"
    exit 0
fi

# Step 3: 计算截止时间（毫秒级 epoch）
if [[ "$OSTYPE" == "darwin"* ]]; then
  CUTOFF_EPOCH_MS=$(python3 -c "
import time, datetime
cutoff = datetime.datetime.now() - datetime.timedelta(days=${RETENTION_DAYS})
print(int(cutoff.timestamp() * 1000))
")
else
  CUTOFF_EPOCH_MS=$(date -d "${RETENTION_DAYS} days ago" +%s%3N)
fi

CUTOFF_DATE=$(python3 -c "
import datetime
print(datetime.datetime.fromtimestamp(${CUTOFF_EPOCH_MS}/1000).strftime('%Y-%m-%d'))
")

echo "🕐 截止日期: ${CUTOFF_DATE} (${CUTOFF_EPOCH_MS} ms)"
echo ""

# Step 4: 找旧 + 低价值记忆
echo "🔍 查找旧的低价值记忆 (>${RETENTION_DAYS} 天, 重要性 < ${MIN_IMPORTANCE})..."

OLD_IDS=$(jq -r --argjson cutoff "${CUTOFF_EPOCH_MS}" --argjson minImp "${MIN_IMPORTANCE}" '
  map(select(
      (.timestamp // 0) < $cutoff
      and ((.importance // 0) < $minImp)
    ))
  | sort_by(.timestamp)
' "${TEMP_FILE}")

OLD_COUNT=$(echo "${OLD_IDS}" | jq 'length')
echo "找到 ${OLD_COUNT} 条旧的低价值记忆"

if [ "${OLD_COUNT}" -gt 0 ]; then
  echo ""
  echo "预览（前 5 条）:"
  echo "${OLD_IDS}" | jq -r '.[0:5][] | "  [\(.id | .[0:8])] 重要性=\(.importance // 0) 分类=\(.category // "?") \(.text | .[0:80])..."'
  echo ""

  if [ "${DRY_RUN}" = "true" ]; then
    echo "[模拟运行] 将归档并删除 ${OLD_COUNT} 条记忆"
  else
    # 归档
    mkdir -p "${ARCHIVE_DIR}"
    ARCHIVE_FILE="${ARCHIVE_DIR}/agent-${AGENT_ID}-old-$(date +%Y%m%d-%H%M%S).json"
    echo "${OLD_IDS}" | jq '.' > "${ARCHIVE_FILE}"
    echo "📦 已归档到: ${ARCHIVE_FILE}"

    # 逐条删除
    DELETED=0
    FAILED=0
    echo "${OLD_IDS}" | jq -r '.[].id' | while read -r mem_id; do
      if openclaw memory forget --memory-id "${mem_id}" 2>&1 | grep -q "deleted\|removed\|forgotten"; then
        DELETED=$((DELETED + 1))
      else
        FAILED=$((FAILED + 1))
        echo "  ⚠️  删除失败: ${mem_id}"
      fi
    done
    echo "✅ 已删除旧记忆（已先归档）"
  fi
fi

# Step 5: 找完全重复记忆
echo ""
echo "🔍 检查完全重复的记忆..."

DUPLICATE_GROUPS=$(jq '
  group_by(.text)
  | map(select(length > 1))
' "${TEMP_FILE}")

DUPLICATE_GROUP_COUNT=$(echo "${DUPLICATE_GROUPS}" | jq 'length')

if [ "${DUPLICATE_GROUP_COUNT}" -gt 0 ]; then
  TOTAL_DUPLICATES=$(echo "${DUPLICATE_GROUPS}" | jq '[.[] | length - 1] | add')
  echo "找到 ${DUPLICATE_GROUP_COUNT} 组重复记忆（${TOTAL_DUPLICATES} 条多余副本）"

  echo ""
  echo "预览:"
  echo "${DUPLICATE_GROUPS}" | jq -r '.[0:3][] |
    "  组 (\(length) 个副本): \(.[0].text | .[0:60])..."'

  if [ "${DRY_RUN}" = "true" ]; then
    echo ""
    echo "[模拟运行] 将保留每组最新副本，删除 ${TOTAL_DUPLICATES} 条重复记忆"
  else
    # 每组保留最新的（timestamp 最大的），删除其余
    DEDUP_IDS=$(echo "${DUPLICATE_GROUPS}" | jq -r '
      .[]
      | sort_by(-(.timestamp // 0))
      | .[1:][]
      | .id
    ')

    DEDUP_DELETED=0
    echo "${DEDUP_IDS}" | while read -r mem_id; do
      [ -z "$mem_id" ] && continue
      openclaw memory forget --memory-id "${mem_id}" 2>&1 | grep -v "plugin" > /dev/null
      DEDUP_DELETED=$((DEDUP_DELETED + 1))
    done
    echo "✅ 去重完成"
  fi
else
  echo "未找到完全重复的记忆 ✅"
fi

# Step 6: 最终状态
echo ""
echo "📊 最终记忆统计:"
if command -v openclaw >/dev/null 2>&1; then
  openclaw memory stats --scope "agent:${AGENT_ID}" 2>&1 | grep -v "plugin" || true
fi

echo ""
echo "=== 压缩完成 ==="
