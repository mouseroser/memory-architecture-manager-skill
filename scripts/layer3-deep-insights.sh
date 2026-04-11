#!/bin/bash
# Layer 3 深度洞察脚本
# 检测 Layer 3 配置并生成深度洞察

set -e

WORKSPACE="$HOME/.openclaw/workspace"
REPORT_FILE="$WORKSPACE/memory/layer3-insights-$(date +%Y%m%d).md"

echo "# Layer 3 深度洞察报告" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**日期**: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 检测 Layer 3 配置
LAYER3_TYPE="none"
LAYER3_AVAILABLE=false

if [ -d "$HOME/.openclaw/extensions/notebooklm" ]; then
    LAYER3_TYPE="notebooklm"
    LAYER3_AVAILABLE=true
    echo "## Layer 3 配置" >> "$REPORT_FILE"
    echo "- ✅ NotebookLM 已配置" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
elif [ -d "$HOME/.openclaw/extensions/lossless-claw-enhanced" ]; then
    LAYER3_TYPE="lossless-claw-enhanced"
    LAYER3_AVAILABLE=true
    echo "## Layer 3 配置" >> "$REPORT_FILE"
    echo "- ✅ lossless-claw-enhanced 已配置（可用作 Layer 3）" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
else
    echo "## Layer 3 配置" >> "$REPORT_FILE"
    echo "- ❌ Layer 3 未配置" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "💡 **建议**: 配置 Layer 3 以启用深度洞察功能" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "**可选方案**:" >> "$REPORT_FILE"
    echo "1. NotebookLM（云端，支持生成洞察）" >> "$REPORT_FILE"
    echo "2. lossless-claw-enhanced（本地 DAG 归档）" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    cat "$REPORT_FILE"
    exit 0
fi

# 如果 Layer 3 可用，生成洞察
echo "## 深度洞察" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ "$LAYER3_TYPE" = "notebooklm" ]; then
    # NotebookLM 洞察生成
    NLM_GATEWAY="$HOME/.openclaw/skills/notebooklm/scripts/nlm-gateway.sh"
    
    if [ ! -x "$NLM_GATEWAY" ]; then
        echo "⚠️ NotebookLM gateway 不可用" >> "$REPORT_FILE"
        cat "$REPORT_FILE"
        exit 0
    fi
    
    echo "### 1. 记忆质量分析" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    QUALITY_RESULT=$(bash "$NLM_GATEWAY" query \
        --agent main \
        --notebook memory-archive \
        --query "分析最近的记忆质量，是否有重复、噪音或低价值记忆？" 2>/dev/null || echo "查询失败")
    
    if [ "$QUALITY_RESULT" != "查询失败" ]; then
        echo "$QUALITY_RESULT" >> "$REPORT_FILE"
    else
        echo "⚠️ 查询失败" >> "$REPORT_FILE"
    fi
    echo "" >> "$REPORT_FILE"
    
    echo "### 2. 改进建议" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    IMPROVEMENT_RESULT=$(bash "$NLM_GATEWAY" query \
        --agent main \
        --notebook memory-archive \
        --query "基于历史记忆，提供 3 条具体的改进建议" 2>/dev/null || echo "查询失败")
    
    if [ "$IMPROVEMENT_RESULT" != "查询失败" ]; then
        echo "$IMPROVEMENT_RESULT" >> "$REPORT_FILE"
    else
        echo "⚠️ 查询失败" >> "$REPORT_FILE"
    fi
    echo "" >> "$REPORT_FILE"
    
elif [ "$LAYER3_TYPE" = "lossless-claw-enhanced" ]; then
    # lossless-claw-enhanced 洞察生成
    echo "### 基于 lossless-claw-enhanced 的洞察" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "- 使用 lcm_grep 搜索历史模式" >> "$REPORT_FILE"
    echo "- 使用 lcm_expand 展开关键摘要" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "💡 **提示**: 使用 lcm_grep 和 lcm_expand 工具进行深度分析" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**报告生成时间**: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "**Layer 3 类型**: $LAYER3_TYPE" >> "$REPORT_FILE"

cat "$REPORT_FILE"
