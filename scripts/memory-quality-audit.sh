#!/bin/bash
# Memory Quality Audit Script
# 检查记忆系统的健康状态

set -euo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
REPORT_DATE=$(date +%Y%m%d)
REPORT_FILE="$MEMORY_DIR/audit-$REPORT_DATE.md"
REPORT_TS=$(date +"%Y-%m-%d %H:%M:%S")

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

ALERT_COUNT=0
ERROR_COUNT=0

warn() {
  ALERT_COUNT=$((ALERT_COUNT + 1))
  echo -e "${YELLOW}⚠️  $1${NC}"
}

fail_check() {
  ALERT_COUNT=$((ALERT_COUNT + 1))
  ERROR_COUNT=$((ERROR_COUNT + 1))
  echo -e "${RED}❌ $1${NC}"
}

mkdir -p "$MEMORY_DIR"

cat > "$REPORT_FILE" <<EOF
# Memory Quality Audit Report

**Date:** $REPORT_TS
**Auditor:** memory-architecture-manager (memory-quality-audit cron)

---

## 审计项目

EOF

echo "🔍 开始记忆质量审计..."

echo "## 1. MEMORY.md 状态" >> "$REPORT_FILE"
if [ -f "$WORKSPACE/MEMORY.md" ]; then
    MEMORY_SIZE=$(wc -c < "$WORKSPACE/MEMORY.md")
    MEMORY_LINES=$(wc -l < "$WORKSPACE/MEMORY.md")
    echo "✅ **状态:** 存在" >> "$REPORT_FILE"
    echo "- **大小:** $MEMORY_SIZE bytes" >> "$REPORT_FILE"
    echo "- **行数:** $MEMORY_LINES lines" >> "$REPORT_FILE"

    if [ "$MEMORY_SIZE" -gt 100000 ]; then
        echo "⚠️ **警告:** MEMORY.md 过大 (>100KB)，建议归档旧内容" >> "$REPORT_FILE"
        warn "MEMORY.md 过大"
    fi
else
    echo "❌ **状态:** 不存在" >> "$REPORT_FILE"
    fail_check "MEMORY.md 不存在"
fi
echo "" >> "$REPORT_FILE"

echo "## 2. 每日记忆文件" >> "$REPORT_FILE"
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)

if [ -f "$MEMORY_DIR/$TODAY.md" ]; then
    echo "✅ **今日记忆:** 存在 ($TODAY.md)" >> "$REPORT_FILE"
else
    echo "⚠️ **今日记忆:** 不存在 ($TODAY.md)" >> "$REPORT_FILE"
    warn "今日记忆文件不存在"
fi

if [ -f "$MEMORY_DIR/$YESTERDAY.md" ]; then
    echo "✅ **昨日记忆:** 存在 ($YESTERDAY.md)" >> "$REPORT_FILE"
else
    echo "⚠️ **昨日记忆:** 不存在 ($YESTERDAY.md)" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

echo "## 3. Shared Context 状态" >> "$REPORT_FILE"
SHARED_DIR="$WORKSPACE/shared-context"
if [ -d "$SHARED_DIR" ]; then
    echo "✅ **目录:** 存在" >> "$REPORT_FILE"
    echo "- **文件列表:**" >> "$REPORT_FILE"
    ls -1 "$SHARED_DIR" | while read -r file; do
        echo "  - $file" >> "$REPORT_FILE"
    done

    for key_file in THESIS.md FEEDBACK-LOG.md SIGNALS.md; do
        if [ ! -f "$SHARED_DIR/$key_file" ]; then
            echo "⚠️ **警告:** 缺少关键文件 $key_file" >> "$REPORT_FILE"
            warn "缺少 $key_file"
        fi
    done
else
    echo "❌ **目录:** 不存在" >> "$REPORT_FILE"
    fail_check "shared-context 目录不存在"
fi
echo "" >> "$REPORT_FILE"

echo "## 4. Intel 协作文件" >> "$REPORT_FILE"
INTEL_DIR="$WORKSPACE/intel"
if [ -d "$INTEL_DIR" ]; then
    echo "✅ **目录:** 存在" >> "$REPORT_FILE"
    FILE_COUNT=$(ls -1 "$INTEL_DIR" 2>/dev/null | wc -l | tr -d ' ')
    echo "- **文件数量:** $FILE_COUNT" >> "$REPORT_FILE"

    if [ "$FILE_COUNT" -eq 0 ]; then
        echo "⚠️ **提示:** intel 目录为空" >> "$REPORT_FILE"
    fi
else
    echo "⚠️ **目录:** 不存在" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

echo "## 5. 记忆文件统计" >> "$REPORT_FILE"
if [ -d "$MEMORY_DIR" ]; then
    TOTAL_FILES=$(find "$MEMORY_DIR" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')
    echo "- **总文件数:** $TOTAL_FILES" >> "$REPORT_FILE"

    RECENT_COUNT=0
    for i in 0 1 2 3 4 5 6; do
        CHECK_DATE=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "$i days ago" +%Y-%m-%d)
        if [ -f "$MEMORY_DIR/$CHECK_DATE.md" ]; then
            RECENT_COUNT=$((RECENT_COUNT + 1))
        fi
    done
    echo "- **最近7天文件数:** $RECENT_COUNT / 7" >> "$REPORT_FILE"

    if [ "$RECENT_COUNT" -lt 5 ]; then
        echo "⚠️ **警告:** 最近7天记忆文件不完整" >> "$REPORT_FILE"
        warn "最近7天记忆文件不完整 ($RECENT_COUNT/7)"
    fi
else
    echo "❌ **memory 目录不存在**" >> "$REPORT_FILE"
    fail_check "memory 目录不存在"
fi
echo "" >> "$REPORT_FILE"

echo "## 6. Layer 2 噪音审计" >> "$REPORT_FILE"
LANCEDB_DIR="$HOME/.openclaw/memory/lancedb-pro"
if [ -d "$LANCEDB_DIR" ]; then
    NOISE_RAW=$(python3 <<'PYEOF'
import json
try:
    import lancedb
    db = lancedb.connect('$LANCEDB_DIR')
    tbl = db.open_table('memories')
    patterns = {
        'system_events': "text LIKE 'System: [%'",
        'conversation_info': "text LIKE '%Conversation info%'",
        'sender_metadata': "text LIKE '%Sender (untrusted metadata)%'",
    }
    out = {}
    for k, where in patterns.items():
        rows = tbl.search().where(where).select(['id']).limit(200).to_list()
        out[k] = len(rows)
    print(json.dumps(out, ensure_ascii=False))
except Exception as e:
    print(json.dumps({'error': str(e)}))
PYEOF
)
    if echo "$NOISE_RAW" | grep -q '"error"'; then
        echo "⚠️ **Layer 2 噪音审计失败:** $NOISE_RAW" >> "$REPORT_FILE"
        warn "Layer 2 噪音审计失败"
    else
        SYSTEM_COUNT=$(echo "$NOISE_RAW" | python3 -c 'import sys, json; print(json.load(sys.stdin).get("system_events", 0))')
        CONV_COUNT=$(echo "$NOISE_RAW" | python3 -c 'import sys, json; print(json.load(sys.stdin).get("conversation_info", 0))')
        SENDER_COUNT=$(echo "$NOISE_RAW" | python3 -c 'import sys, json; print(json.load(sys.stdin).get("sender_metadata", 0))')
        TOTAL_NOISE=$((SYSTEM_COUNT + CONV_COUNT + SENDER_COUNT))
        echo "- **system_events:** $SYSTEM_COUNT" >> "$REPORT_FILE"
        echo "- **conversation_info:** $CONV_COUNT" >> "$REPORT_FILE"
        echo "- **sender_metadata:** $SENDER_COUNT" >> "$REPORT_FILE"
        if [ "$TOTAL_NOISE" -gt 0 ]; then
            echo "⚠️ **警告:** Layer 2 中仍有 $TOTAL_NOISE 条明显系统包络噪音记忆" >> "$REPORT_FILE"
            warn "Layer 2 存在系统包络噪音 ($TOTAL_NOISE 条)"
        else
            echo "✅ **状态:** 未发现明显系统包络噪音" >> "$REPORT_FILE"
        fi
    fi
else
    echo "⚠️ **Layer 2 数据目录不存在:** $LANCEDB_DIR" >> "$REPORT_FILE"
    warn "Layer 2 数据目录不存在"
fi

echo "" >> "$REPORT_FILE"
echo "## 审计总结" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- **告警总数:** $ALERT_COUNT" >> "$REPORT_FILE"
echo "- **错误总数:** $ERROR_COUNT" >> "$REPORT_FILE"
echo "- **完成时间:** $(date +"%Y-%m-%d %H:%M:%S")" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*此报告由 memory-quality-audit cron 自动生成*" >> "$REPORT_FILE"

echo "✅ 审计报告已生成: $REPORT_FILE"
if [ "$ALERT_COUNT" -gt 0 ]; then
    echo "⚠️  发现 $ALERT_COUNT 个告警（其中错误 $ERROR_COUNT 个）"
else
    echo -e "${GREEN}✅ 所有检查通过${NC}"
fi

# 对预期的告警保持 0 退出码，避免 cron 因审计发现告警而直接失败。
exit 0
