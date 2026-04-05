#!/bin/bash
# Layer 2 (memory-lancedb-pro) 健康检查脚本

set -e

WORKSPACE="$HOME/.openclaw/workspace"
REPORT_FILE="$WORKSPACE/memory/layer2-health-$(date +%Y%m%d).md"

echo "# Layer 2 健康检查报告" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**日期**: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 1. 检查向量数据库
echo "## 1. 向量数据库状态" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 从配置文件读取实际路径
DB_PATH=$(jq -r '.plugins.entries."memory-lancedb-pro".config.dbPath // "~/.openclaw/memory/lancedb-pro"' ~/.openclaw/openclaw.json)
# 展开 ~ 为实际路径
DB_PATH="${DB_PATH/#\~/$HOME}"

if [ -d "$DB_PATH" ]; then
    DB_SIZE=$(du -sh "$DB_PATH" | cut -f1)
    FILE_COUNT=$(find "$DB_PATH" -type f | wc -l)
    echo "- ✅ 数据库路径: $DB_PATH" >> "$REPORT_FILE"
    echo "- ✅ 数据库大小: $DB_SIZE" >> "$REPORT_FILE"
    echo "- ✅ 文件数量: $FILE_COUNT" >> "$REPORT_FILE"
else
    echo "- ❌ 数据库路径不存在: $DB_PATH" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# 2. 检查 rerank sidecar
echo "## 2. Rerank Sidecar 状态" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if curl -s http://127.0.0.1:8765/health > /dev/null 2>&1; then
    echo "- ✅ Rerank sidecar 运行正常" >> "$REPORT_FILE"
else
    echo "- ⚠️ Rerank sidecar 不可达，尝试检查 launchd 服务..." >> "$REPORT_FILE"
    if launchctl list | grep -q "com.openclaw.local-rerank-sidecar"; then
        echo "- ⚠️ Launchd 服务已加载，但端口不响应" >> "$REPORT_FILE"
    else
        echo "- ❌ Launchd 服务未加载" >> "$REPORT_FILE"
    fi
fi
echo "" >> "$REPORT_FILE"

# 3. 检查自动捕获
echo "## 3. 自动捕获状态" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 检查最近的捕获记录
RECENT_CAPTURES=$(grep -r "source=auto-capture" "$WORKSPACE/memory/$(date +%Y-%m-%d).md" 2>/dev/null | wc -l || echo "0")
echo "- 今日自动捕获次数: $RECENT_CAPTURES" >> "$REPORT_FILE"

if [ "$RECENT_CAPTURES" -gt 0 ]; then
    echo "- ✅ 自动捕获正常工作" >> "$REPORT_FILE"
else
    echo "- ⚠️ 今日尚无自动捕获记录（可能是时间太早）" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# 4. 检查召回质量（通过 Ollama embedding API 直连验证）
# builtin memorySearch 已关闭（2026-03-15），改为直接测试 Ollama embedding 可用性
# memory-lancedb-pro 的 autoRecall 才是实际召回链路
echo "## 4. 召回质量检查" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

RECALL_OK=0
RECALL_COUNT=0

# 测试 Ollama embedding API 是否正常（memory-lancedb-pro 的底层依赖）
EMBED_TEST=$(curl -sf -X POST http://127.0.0.1:11434/api/embeddings \
  -d '{"model":"nomic-embed-text","prompt":"test"}' 2>&1 || true)

if echo "$EMBED_TEST" | grep -q '"embedding"'; then
    RECALL_OK=1
    RECALL_COUNT=1
    echo "- ✅ Ollama embedding API 正常（nomic-embed-text）" >> "$REPORT_FILE"
else
    echo "- ❌ Ollama embedding API 异常" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
    echo "$EMBED_TEST" | head -5 >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# 5. 生成健康评分
echo "## 5. 健康评分" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

SCORE=0
[ -d "$DB_PATH" ] && SCORE=$((SCORE + 25))
curl -s http://127.0.0.1:8765/health > /dev/null 2>&1 && SCORE=$((SCORE + 25))
[ "$RECENT_CAPTURES" -gt 0 ] && SCORE=$((SCORE + 25))
[ "$RECALL_OK" -eq 1 ] && [ "$RECALL_COUNT" -gt 0 ] && SCORE=$((SCORE + 25))

if [ $SCORE -ge 75 ]; then
    echo "- ✅ **健康评分**: $SCORE/100（良好）" >> "$REPORT_FILE"
elif [ $SCORE -ge 50 ]; then
    echo "- ⚠️ **健康评分**: $SCORE/100（一般）" >> "$REPORT_FILE"
else
    echo "- ❌ **健康评分**: $SCORE/100（需要关注）" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# 6. 建议
echo "## 6. 建议" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ $SCORE -lt 75 ]; then
    echo "- 检查 rerank sidecar 是否正常运行" >> "$REPORT_FILE"
    echo "- 运行 \`bash ~/.openclaw/scripts/status-local-rerank-sidecar.sh\`" >> "$REPORT_FILE"
    echo "- 如果需要重启：\`launchctl kickstart -k gui/$(id -u)/com.openclaw.local-rerank-sidecar\`" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

echo "---" >> "$REPORT_FILE"
echo "**报告路径**: $REPORT_FILE" >> "$REPORT_FILE"

# 输出报告路径
echo "$REPORT_FILE"
