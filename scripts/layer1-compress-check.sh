#!/bin/bash
# Layer 1 (本地文件) 压缩检查脚本
# 检查超过阈值的每日日志，生成压缩版本（保留原始文件）

set -e

WORKSPACE="$HOME/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
ARCHIVE_DIR="$MEMORY_DIR/archive"
REPORT_FILE="$MEMORY_DIR/layer1-compress-$(date +%Y%m%d).md"
TOKEN_THRESHOLD=40000

# 创建归档目录
mkdir -p "$ARCHIVE_DIR"

echo "# Layer 1 压缩检查报告" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**日期**: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "**阈值**: $TOKEN_THRESHOLD tokens" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 检测 tiktoken（更准确的 token 计数）
TIKTOKEN_AVAILABLE=false
if command -v python3 >/dev/null 2>&1; then
  if python3 -c "import tiktoken" 2>/dev/null; then
    TIKTOKEN_AVAILABLE=true
  fi
fi

# Token 计数函数
count_tokens() {
  local file="$1"
  if [ "$TIKTOKEN_AVAILABLE" = true ]; then
    python3 -c "
import tiktoken
enc = tiktoken.get_encoding('cl100k_base')
with open('$file', 'r', encoding='utf-8') as f:
    text = f.read()
print(len(enc.encode(text)))
" 2>/dev/null || echo $(($(wc -c < "$file") / 4))
  else
    # 回退：字符数 / 4
    echo $(($(wc -c < "$file") / 4))
  fi
}

# 1. 扫描所有每日日志
echo "## 1. 扫描每日日志" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ "$TIKTOKEN_AVAILABLE" = true ]; then
  echo "- Token 计数方式: tiktoken (cl100k_base) ✅" >> "$REPORT_FILE"
else
  echo "- Token 计数方式: 字符数 / 4 (估算) ⚠️" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

TOTAL_FILES=0
LARGE_FILES=0
COMPRESSED_FILES=0

for file in "$MEMORY_DIR"/202*.md; do
    [ -f "$file" ] || continue
    
    # 跳过已归档的文件
    basename=$(basename "$file")
    if [[ "$basename" == *"-daily.md" ]] || [[ "$basename" == *"-compress-"* ]] || [[ "$basename" == *"-audit-"* ]]; then
        continue
    fi
    
    TOTAL_FILES=$((TOTAL_FILES + 1))
    
    # 计算 token 数
    TOKEN_COUNT=$(count_tokens "$file")
    
    if [ $TOKEN_COUNT -gt $TOKEN_THRESHOLD ]; then
        LARGE_FILES=$((LARGE_FILES + 1))
        echo "- ⚠️ **$basename**: ~$TOKEN_COUNT tokens（超过阈值）" >> "$REPORT_FILE"
        
        # 生成压缩版本（保留原始文件）
        COMPRESSED_FILE="$ARCHIVE_DIR/${basename%.md}-compressed.md"
        
        echo "# 压缩版：$basename" > "$COMPRESSED_FILE"
        echo "" >> "$COMPRESSED_FILE"
        echo "**原始文件**: $file" >> "$COMPRESSED_FILE"
        echo "**原始大小**: ~$TOKEN_COUNT tokens" >> "$COMPRESSED_FILE"
        echo "**压缩时间**: $(date '+%Y-%m-%d %H:%M:%S')" >> "$COMPRESSED_FILE"
        echo "" >> "$COMPRESSED_FILE"
        echo "## 关键事件" >> "$COMPRESSED_FILE"
        echo "" >> "$COMPRESSED_FILE"
        
        # 提取关键行（包含 ✅ ❌ ⚠️ 的行）
        grep -E "(✅|❌|⚠️)" "$file" >> "$COMPRESSED_FILE" 2>/dev/null || echo "（无关键事件标记）" >> "$COMPRESSED_FILE"
        
        echo "" >> "$COMPRESSED_FILE"
        echo "---" >> "$COMPRESSED_FILE"
        echo "**注意**: 这是压缩版本，完整内容见原始文件" >> "$COMPRESSED_FILE"
        
        COMPRESSED_FILES=$((COMPRESSED_FILES + 1))
        echo "  - 已生成压缩版本: $COMPRESSED_FILE" >> "$REPORT_FILE"
        echo "  - 原始文件保留: $file" >> "$REPORT_FILE"
    fi
done

echo "" >> "$REPORT_FILE"
echo "- 总文件数: $TOTAL_FILES" >> "$REPORT_FILE"
echo "- 超过阈值: $LARGE_FILES" >> "$REPORT_FILE"
echo "- 已生成压缩版本: $COMPRESSED_FILES" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 2. 检查 MEMORY.md 大小
echo "## 2. MEMORY.md 检查" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

MEMORY_MD="$WORKSPACE/MEMORY.md"
if [ -f "$MEMORY_MD" ]; then
    MEMORY_TOKEN_COUNT=$(count_tokens "$MEMORY_MD")
    
    echo "- MEMORY.md 大小: ~$MEMORY_TOKEN_COUNT tokens" >> "$REPORT_FILE"
    
    if [ $MEMORY_TOKEN_COUNT -gt $TOKEN_THRESHOLD ]; then
        echo "- ⚠️ MEMORY.md 超过阈值，建议手动精简" >> "$REPORT_FILE"
    else
        echo "- ✅ MEMORY.md 大小正常" >> "$REPORT_FILE"
    fi
else
    echo "- ❌ MEMORY.md 不存在" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# 3. 归档目录统计
echo "## 3. 归档目录统计" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

ARCHIVE_SIZE=$(du -sh "$ARCHIVE_DIR" 2>/dev/null | cut -f1 || echo "0")
ARCHIVE_FILE_COUNT=$(find "$ARCHIVE_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')

echo "- 归档目录: $ARCHIVE_DIR" >> "$REPORT_FILE"
echo "- 归档大小: $ARCHIVE_SIZE" >> "$REPORT_FILE"
echo "- 归档文件数: $ARCHIVE_FILE_COUNT" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 4. 建议
echo "## 4. 建议" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ $COMPRESSED_FILES -gt 0 ]; then
    echo "- ✅ 已生成 $COMPRESSED_FILES 个压缩版本" >> "$REPORT_FILE"
    echo "- 原始文件已保留在 $MEMORY_DIR" >> "$REPORT_FILE"
    echo "- 压缩版本保存在 $ARCHIVE_DIR" >> "$REPORT_FILE"
fi

if [ $MEMORY_TOKEN_COUNT -gt $TOKEN_THRESHOLD ]; then
    echo "- ⚠️ MEMORY.md 需要精简，建议移除过时内容" >> "$REPORT_FILE"
fi

if [ "$TIKTOKEN_AVAILABLE" = false ]; then
    echo "- 💡 安装 tiktoken 以获得更准确的 token 计数：\`pip install tiktoken\`" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "**报告路径**: $REPORT_FILE" >> "$REPORT_FILE"

# 输出报告路径
echo "✅ 报告已生成: $REPORT_FILE"
cat "$REPORT_FILE"
