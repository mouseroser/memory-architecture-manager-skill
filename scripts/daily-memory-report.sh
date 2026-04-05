#!/bin/bash
# Daily Memory System Report
# 生成每日记忆系统状态报告

WORKSPACE="$HOME/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
REPORT_DATE=$(date +%Y%m%d)
REPORT_FILE="/tmp/memory-system-daily-report-$REPORT_DATE.md"

# 初始化报告
cat > "$REPORT_FILE" << EOF
# 📊 每日记忆系统报告

**日期:** $(date +"%Y-%m-%d %H:%M:%S")
**生成者:** memory-architecture-manager (daily-memory-report cron)

---

EOF

# 0. 检测 Layer 2 插件
echo "## 🔌 Layer 2 插件状态" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

LAYER2A_INSTALLED=false
LAYER2B_INSTALLED=false

if [ -d "$HOME/.openclaw/extensions/memory-lancedb-pro" ]; then
    LAYER2A_INSTALLED=true
    echo "✅ **Layer 2A (memory-lancedb-pro):** 已安装" >> "$REPORT_FILE"
else
    echo "❌ **Layer 2A (memory-lancedb-pro):** 未安装" >> "$REPORT_FILE"
fi

if [ -d "$HOME/.openclaw/extensions/lossless-claw-enhanced" ]; then
    LAYER2B_INSTALLED=true
    echo "✅ **Layer 2B (lossless-claw-enhanced):** 已安装" >> "$REPORT_FILE"
else
    echo "❌ **Layer 2B (lossless-claw-enhanced):** 未安装" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# 1. 系统健康状态
echo "## 🏥 系统健康状态" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 检查 MEMORY.md
if [ -f "$WORKSPACE/MEMORY.md" ]; then
    MEMORY_SIZE=$(wc -c < "$WORKSPACE/MEMORY.md")
    MEMORY_LINES=$(wc -l < "$WORKSPACE/MEMORY.md")
    echo "✅ **MEMORY.md:** 存在 ($MEMORY_LINES 行, $(($MEMORY_SIZE / 1024)) KB)" >> "$REPORT_FILE"
else
    echo "❌ **MEMORY.md:** 不存在" >> "$REPORT_FILE"
fi

# 检查今日和昨日记忆文件
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)

if [ -f "$MEMORY_DIR/$TODAY.md" ]; then
    TODAY_SIZE=$(wc -l < "$MEMORY_DIR/$TODAY.md")
    echo "✅ **今日记忆 ($TODAY):** 存在 ($TODAY_SIZE 行)" >> "$REPORT_FILE"
else
    echo "⚠️ **今日记忆 ($TODAY):** 不存在" >> "$REPORT_FILE"
fi

if [ -f "$MEMORY_DIR/$YESTERDAY.md" ]; then
    YESTERDAY_SIZE=$(wc -l < "$MEMORY_DIR/$YESTERDAY.md")
    echo "✅ **昨日记忆 ($YESTERDAY):** 存在 ($YESTERDAY_SIZE 行)" >> "$REPORT_FILE"
else
    echo "⚠️ **昨日记忆 ($YESTERDAY):** 不存在" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# 2. Layer 2A 状态（如果已安装）
if [ "$LAYER2A_INSTALLED" = true ]; then
    echo "## 📊 Layer 2A (memory-lancedb-pro) 状态" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    if command -v openclaw >/dev/null 2>&1; then
        MEMORY_STATS=$(openclaw memory stats 2>/dev/null || echo "")
        if [ -n "$MEMORY_STATS" ]; then
            echo '```' >> "$REPORT_FILE"
            echo "$MEMORY_STATS" >> "$REPORT_FILE"
            echo '```' >> "$REPORT_FILE"
        else
            echo "⚠️ 无法获取 memory stats" >> "$REPORT_FILE"
        fi
    else
        echo "⚠️ openclaw 命令不可用" >> "$REPORT_FILE"
    fi
    
    echo "" >> "$REPORT_FILE"
fi

# 3. 记忆文件统计
echo "## 📈 记忆文件统计" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ -d "$MEMORY_DIR" ]; then
    TOTAL_FILES=$(ls -1 "$MEMORY_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "- **总文件数:** $TOTAL_FILES" >> "$REPORT_FILE"
    
    # 最近7天的文件
    RECENT_COUNT=0
    for i in {0..6}; do
        CHECK_DATE=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "$i days ago" +%Y-%m-%d)
        if [ -f "$MEMORY_DIR/$CHECK_DATE.md" ]; then
            RECENT_COUNT=$((RECENT_COUNT + 1))
        fi
    done
    echo "- **最近7天完整度:** $RECENT_COUNT / 7" >> "$REPORT_FILE"
    
    # 最近30天的文件
    MONTH_COUNT=0
    for i in {0..29}; do
        CHECK_DATE=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "$i days ago" +%Y-%m-%d)
        if [ -f "$MEMORY_DIR/$CHECK_DATE.md" ]; then
            MONTH_COUNT=$((MONTH_COUNT + 1))
        fi
    done
    echo "- **最近30天完整度:** $MONTH_COUNT / 30" >> "$REPORT_FILE"
else
    echo "❌ **memory 目录不存在**" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# 4. Shared Context 状态
echo "## 🤝 Shared Context 状态" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

SHARED_DIR="$WORKSPACE/shared-context"
if [ -d "$SHARED_DIR" ]; then
    for key_file in THESIS.md FEEDBACK-LOG.md SIGNALS.md PATHS.md; do
        if [ -f "$SHARED_DIR/$key_file" ]; then
            FILE_SIZE=$(wc -l < "$SHARED_DIR/$key_file" | tr -d ' ')
            echo "✅ **$key_file:** 存在 ($FILE_SIZE 行)" >> "$REPORT_FILE"
        else
            echo "❌ **$key_file:** 不存在" >> "$REPORT_FILE"
        fi
    done
else
    echo "❌ **shared-context 目录不存在**" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# 5. Intel 协作文件
echo "## 📁 Intel 协作文件" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

INTEL_DIR="$WORKSPACE/intel"
if [ -d "$INTEL_DIR" ]; then
    FILE_COUNT=$(find "$INTEL_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "- **文件数量:** $FILE_COUNT" >> "$REPORT_FILE"
    
    if [ $FILE_COUNT -gt 0 ]; then
        echo "- **最近更新:**" >> "$REPORT_FILE"
        find "$INTEL_DIR" -type f -exec ls -lt {} + 2>/dev/null | head -5 | awk '{print "  - " $9}' >> "$REPORT_FILE"
    fi
else
    echo "⚠️ **intel 目录不存在**" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# 6. 最近活动摘要
echo "## 🔄 最近活动摘要" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ -f "$MEMORY_DIR/$YESTERDAY.md" ]; then
    echo "### 昨日记忆摘要 ($YESTERDAY)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
    head -20 "$MEMORY_DIR/$YESTERDAY.md" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "*（显示前20行，完整内容见 memory/$YESTERDAY.md）*" >> "$REPORT_FILE"
else
    echo "⚠️ 昨日记忆文件不存在" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# 7. 总结
echo "## 📝 总结" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 统计告警数量
ERROR_COUNT=$(grep -c "❌" "$REPORT_FILE" || echo "0")
WARNING_COUNT=$(grep -c "⚠️" "$REPORT_FILE" || echo "0")

if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "🔴 **状态:** 发现 $ERROR_COUNT 个错误" >> "$REPORT_FILE"
elif [ "$WARNING_COUNT" -gt 0 ]; then
    echo "🟡 **状态:** 发现 $WARNING_COUNT 个警告" >> "$REPORT_FILE"
else
    echo "🟢 **状态:** 系统健康" >> "$REPORT_FILE"
fi

# 插件建议
if [ "$LAYER2A_INSTALLED" = false ] || [ "$LAYER2B_INSTALLED" = false ]; then
    echo "" >> "$REPORT_FILE"
    echo "### 💡 插件建议" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    if [ "$LAYER2A_INSTALLED" = false ]; then
        echo "- 安装 Layer 2A: \`openclaw plugins install memory-lancedb-pro@beta\`" >> "$REPORT_FILE"
        echo "  - GitHub: https://github.com/CortexReach/memory-lancedb-pro" >> "$REPORT_FILE"
    fi
    
    if [ "$LAYER2B_INSTALLED" = false ]; then
        echo "- 安装 Layer 2B: \`openclaw plugins install --link ./lossless-claw-enhanced\`" >> "$REPORT_FILE"
        echo "  - GitHub: https://github.com/win4r/lossless-claw-enhanced" >> "$REPORT_FILE"
    fi
fi

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*报告生成时间: $(date +"%Y-%m-%d %H:%M:%S")*" >> "$REPORT_FILE"

echo "✅ 报告已生成: $REPORT_FILE"
cat "$REPORT_FILE"
