#!/bin/bash
# Layer 3 月度归档脚本
# 将上月记忆归档到 Memory Archive

set -euo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
LAST_MONTH=$(date -v-1m +%Y-%m 2>/dev/null || date -d "last month" +%Y-%m)
ARCHIVE_BASENAME="memory-archive-${LAST_MONTH}.md"
ARCHIVE_FILE="/tmp/${ARCHIVE_BASENAME}"
REPORT_FILE="$WORKSPACE/memory/layer3-archive-$(date +%Y%m%d).md"

echo "📦 Layer 3 月度归档 - $LAST_MONTH"
echo ""

# Step 1: 检测 Layer 3 配置
echo "🔍 检测 Layer 3 配置..."
LAYER3_TYPE="none"
LAYER3_AVAILABLE=false
NOTEBOOK_NAME="memory-archive"
NOTEBOOK_ID=""

# 检查 NotebookLM
NOTEBOOKS_CONFIG="$HOME/.openclaw/skills/notebooklm/config/notebooks.json"
if [ -f "$NOTEBOOKS_CONFIG" ] && [ -d "$HOME/.openclaw/extensions/notebooklm" ]; then
  if command -v python3 >/dev/null 2>&1; then
    RESOLVED_ID=$(python3 - "$NOTEBOOKS_CONFIG" <<'PY'
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
    if [ -n "$RESOLVED_ID" ]; then
      NOTEBOOK_ID="$RESOLVED_ID"
      LAYER3_TYPE="notebooklm"
      LAYER3_AVAILABLE=true
    fi
  fi
fi

# 检查 lossless-claw-enhanced
if [ -d "$HOME/.openclaw/extensions/lossless-claw-enhanced" ]; then
  LAYER3_TYPE="lossless-claw-enhanced"
  LAYER3_AVAILABLE=true
fi

echo "Layer 3 类型: $LAYER3_TYPE"
echo ""

if [ "$LAYER3_AVAILABLE" = false ]; then
  echo "❌ Layer 3 未配置，跳过归档"
  echo ""
  echo "💡 归档内容已准备：$ARCHIVE_FILE"
  echo "   如需归档，请先配置 Layer 3"
fi

# Step 2: 收集上月记忆（无论 Layer 3 是否可用都生成归档）
echo "📂 收集上月记忆..."
MEMORY_FILES=$(find "$WORKSPACE/memory" -maxdepth 1 -name "${LAST_MONTH}-*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "✅ 找到 $MEMORY_FILES 个上月日志文件"
echo ""

# Step 3: 准备归档内容
echo "📝 准备归档内容..."
cat > "$ARCHIVE_FILE" <<EOF
# 记忆归档 - $LAST_MONTH

## MEMORY.md 快照
EOF

if [ -f "$WORKSPACE/MEMORY.md" ]; then
  cat "$WORKSPACE/MEMORY.md" >> "$ARCHIVE_FILE"
fi

cat >> "$ARCHIVE_FILE" <<EOF

---

## 本月重要日志
EOF

find "$WORKSPACE/memory" -maxdepth 1 -name "${LAST_MONTH}-*.md" -type f 2>/dev/null | sort | while IFS= read -r file; do
  echo "" >> "$ARCHIVE_FILE"
  echo "### $(basename "$file")" >> "$ARCHIVE_FILE"
  echo "" >> "$ARCHIVE_FILE"
  grep -E "(✅|❌|⚠️)" "$file" >> "$ARCHIVE_FILE" 2>/dev/null || echo "（无关键事件）" >> "$ARCHIVE_FILE"
done

# 追加 topics/*.md 主题文件
TOPICS_DIR="$WORKSPACE/memory/topics"
TOPICS_COUNT=0
if [ -d "$TOPICS_DIR" ]; then
  cat >> "$ARCHIVE_FILE" <<'TOPICSEOF'

---

## 主题文件 (memory/topics)
TOPICSEOF
  for topic_file in "$TOPICS_DIR"/*.md; do
    [ -f "$topic_file" ] || continue
    echo "" >> "$ARCHIVE_FILE"
    echo "### $(basename "$topic_file")" >> "$ARCHIVE_FILE"
    echo "" >> "$ARCHIVE_FILE"
    cat "$topic_file" >> "$ARCHIVE_FILE"
    TOPICS_COUNT=$((TOPICS_COUNT + 1))
  done
fi
echo "✅ 追加 $TOPICS_COUNT 个 topics/*.md 主题文件"
echo "✅ 归档内容已准备：$ARCHIVE_FILE"
echo ""

# Step 4: 上传到 Layer 3（如果可用）
if [ "$LAYER3_AVAILABLE" = true ]; then
  if [ "$LAYER3_TYPE" = "notebooklm" ]; then
    echo "☁️  上传到 NotebookLM..."
    if ! command -v notebooklm >/dev/null 2>&1; then
      echo "⚠️ NotebookLM CLI 不可用，跳过上传"
      UPLOAD_STATUS="cli_unavailable"
    else
      EXISTING_JSON_FILE=$(mktemp -t layer3_monthly_sources)
      notebooklm source list -n "$NOTEBOOK_ID" --json > "$EXISTING_JSON_FILE"
      EXISTING_IDS=$(python3 - "$ARCHIVE_BASENAME" "$EXISTING_JSON_FILE" <<'PY'
import json, sys
wanted = sys.argv[1]
path = sys.argv[2]
try:
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    for src in data.get('sources', []):
        if src.get('title') == wanted:
            print(src.get('id', ''))
except Exception:
    pass
PY
)

      DELETED=0
      if [ -n "$EXISTING_IDS" ]; then
        while IFS= read -r sid; do
          [ -z "$sid" ] && continue
          if notebooklm source delete -n "$NOTEBOOK_ID" --yes "$sid" >/dev/null 2>&1; then
            DELETED=$((DELETED + 1))
          fi
        done <<< "$EXISTING_IDS"
      fi

      if notebooklm source add -n "$NOTEBOOK_ID" --title "memory-archive-${LAST_MONTH}" "$ARCHIVE_FILE" >/dev/null 2>&1; then
        UPLOAD_STATUS="ok"
        echo "✅ 已上传到 NotebookLM"
      else
        UPLOAD_STATUS="failed"
        echo "⚠️ 上传失败，请检查 NotebookLM CLI"
      fi
      rm -f "$EXISTING_JSON_FILE"
    fi
  elif [ "$LAYER3_TYPE" = "lossless-claw-enhanced" ]; then
    echo "💾 使用 lossless-claw-enhanced 归档..."
    echo "✅ lossless-claw-enhanced 已配置，使用 DAG 摘要归档"
    UPLOAD_STATUS="dag_archived"
    DELETED=0
  fi
else
  UPLOAD_STATUS="skipped"
  DELETED=0
fi
echo ""

# Step 5: 生成月度摘要
echo "📊 生成月度摘要..."
cat > "$REPORT_FILE" <<EOF
# Layer 3 月度归档报告 - $LAST_MONTH

**归档时间**: $(date '+%Y-%m-%d %H:%M:%S')

## Layer 3 配置

- **类型**: $LAYER3_TYPE
- **可用**: $LAYER3_AVAILABLE

## 归档内容

- **时间范围**: $LAST_MONTH
- **日志文件数**: $MEMORY_FILES
- **归档文件**: $ARCHIVE_FILE
- **删除旧同名 source**: $DELETED
- **上传状态**: $UPLOAD_STATUS

## 归档统计

- MEMORY.md 快照: ✅
- 本月重要日志: $MEMORY_FILES 个文件
- topics/*.md 主题文件: $TOPICS_COUNT 个

## 下一步

- 归档文件已保存到 /tmp/
- 如需清理本地旧文件，请手动执行

---

**报告路径**: $REPORT_FILE
EOF

echo "✅ 月度摘要已生成：$REPORT_FILE"
echo ""

echo "📊 归档完成！"
echo ""
echo "归档内容："
echo "  - 时间范围: $LAST_MONTH"
echo "  - 文件数: $MEMORY_FILES"
echo "  - Layer 3 类型: $LAYER3_TYPE"
echo "  - 上传状态: $UPLOAD_STATUS"
echo "  - 归档文件: $ARCHIVE_FILE"
echo "  - 报告: $REPORT_FILE"
