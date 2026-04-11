#!/bin/bash
# optimize-memory-architecture.sh - 记忆架构优化脚本（支持人格分层）
# 根据已安装的 Layer 2 插件和 agent 类型优化记忆架构

set -e

WORKSPACE_DIR="${1:-$HOME/.openclaw/workspace}"
EXTENSIONS_DIR="$HOME/.openclaw/extensions"
AGENT_CONFIG_GENERATOR_DIR="$HOME/.openclaw/skills/agent-config-generator"

# 加载 agent 类型检测函数库
if [ -f "$HOME/.openclaw/skills/architecture-generator/scripts/lib-agent-types.sh" ]; then
    source "$HOME/.openclaw/skills/architecture-generator/scripts/lib-agent-types.sh"
else
    echo "⚠️  警告: 未找到 lib-agent-types.sh，将使用默认逻辑"
    detect_agent_type() {
        local agent_dir="$1"
        if [ -f "$agent_dir/USER.md" ]; then
            echo "independent"
        else
            echo "operational"
        fi
    }
fi

echo "=== 记忆架构优化 ==="
echo ""
echo "📁 Workspace: $WORKSPACE_DIR"
echo ""

# 检测插件安装状态
layer2a_installed=false
layer2b_installed=false

if [ -d "$EXTENSIONS_DIR/memory-lancedb-pro" ]; then
    layer2a_installed=true
fi

if [ -d "$EXTENSIONS_DIR/lossless-claw" ] || [ -d "$EXTENSIONS_DIR/lossless-claw-enhanced" ]; then
    layer2b_installed=true
fi

echo "🔍 检测插件状态:"
echo "  - Layer 2A (memory-lancedb-pro): $([ "$layer2a_installed" = true ] && echo '✅ 已安装' || echo '❌ 未安装')"
echo "  - Layer 2B (lossless-claw-enhanced): $([ "$layer2b_installed" = true ] && echo '✅ 已安装' || echo '❌ 未安装')"
echo ""

if [ "$layer2a_installed" = false ] && [ "$layer2b_installed" = false ]; then
    echo "⚠️  未检测到任何 Layer 2 插件"
    echo "   无需记忆架构优化"
    exit 0
fi

# 1. 检查并创建必要的记忆目录
echo "📂 检查记忆目录结构..."

if [ ! -d "$WORKSPACE_DIR/memory" ]; then
    mkdir -p "$WORKSPACE_DIR/memory"
    echo "  ✅ 创建 memory/"
fi

if [ ! -d "$WORKSPACE_DIR/memory/topics" ]; then
    mkdir -p "$WORKSPACE_DIR/memory/topics"
    echo "  ✅ 创建 memory/topics/"
fi

if [ ! -d "$WORKSPACE_DIR/memory/archive" ]; then
    mkdir -p "$WORKSPACE_DIR/memory/archive"
    echo "  ✅ 创建 memory/archive/"
fi

if [ ! -d "$WORKSPACE_DIR/memory/runtime-maintenance" ]; then
    mkdir -p "$WORKSPACE_DIR/memory/runtime-maintenance"
    echo "  ✅ 创建 memory/runtime-maintenance/"
fi

echo ""

# 2. 检查 MEMORY.md
echo "📝 检查 MEMORY.md..."

if [ ! -f "$WORKSPACE_DIR/MEMORY.md" ]; then
    cat > "$WORKSPACE_DIR/MEMORY.md" << 'EOF'
# MEMORY.md - 长期记忆（索引）

> **本文件是索引**，详细内容在 `memory/topics/*.md` 主题文件中。
> 每条索引 ≤1 行 ≤150 字符。详细的 Why / How to apply 见对应主题文件。

---

## 📦 memory_store 写入规范

text 必须包含三部分：规则/事实 + Why + How to apply

```
❌ "browser upload 路径限制在 /tmp/openclaw/uploads/"
✅ "browser upload 路径限制在 /tmp/openclaw/uploads/。Why: sandbox 安全策略。How to apply: 跨目录文件需先 cp"
```

---

## ⚠️ 血泪教训（索引）

（待添加）

---

## ✅ 验证有效的做法（Confirmed Approaches）

（待添加）

---

## 🛡️ 记忆漂移防御

回忆记忆后，执行前必须验证当前状态：
1. 记忆提到文件路径 → 检查文件是否存在
2. 记忆提到 CLI 命令/flag → 先 `--help` 确认
3. 记忆提到配置值 → 读当前配置
4. 记忆提到平台行为/页面结构 → 视为可能过时
5. 用户问"当前/最近"状态 → 优先读实际状态，不依赖记忆快照

**"记忆说 X 存在" ≠ "X 现在存在"**

---

**最后更新**：$(date +%Y-%m-%d)
EOF
    echo "  ✅ 创建 MEMORY.md"
else
    echo "  ✅ MEMORY.md 已存在"
fi

echo ""

# 3. Layer 2A 优化（memory-lancedb-pro）
if [ "$layer2a_installed" = true ]; then
    echo "🔧 Layer 2A (memory-lancedb-pro) 优化..."
    
    # 检查 memory stats
    if command -v openclaw >/dev/null 2>&1; then
        echo "  📊 当前记忆统计:"
        openclaw memory stats 2>/dev/null | head -10 || echo "  ⚠️  无法获取统计信息"
    fi
    
    echo "  ✅ Layer 2A 可用"
    echo ""
fi

# 4. Layer 2B 优化（lossless-claw-enhanced）
if [ "$layer2b_installed" = true ]; then
    echo "🔧 Layer 2B (lossless-claw-enhanced) 优化..."
    echo "  ✅ Layer 2B 可用（自动 DAG 摘要）"
    echo ""
fi

# 5. 创建今日日志（如果不存在）
TODAY=$(date +%Y-%m-%d)
TODAY_LOG="$WORKSPACE_DIR/memory/$TODAY.md"

if [ ! -f "$TODAY_LOG" ]; then
    cat > "$TODAY_LOG" << EOF
# $TODAY

## 重要工作

（待记录）

## 踩坑与修复

（待记录）

## 新增规则

（待记录）
EOF
    echo "📅 创建今日日志: memory/$TODAY.md"
else
    echo "📅 今日日志已存在: memory/$TODAY.md"
fi

echo ""

# 6. 优化 agents/ 子目录的记忆配置（根据类型）
if [ -d "$WORKSPACE_DIR/agents" ]; then
    echo "🤖 优化 agents/ 记忆配置..."
    echo ""
    
    for agent_dir in "$WORKSPACE_DIR/agents"/*; do
        if [ ! -d "$agent_dir" ]; then
            continue
        fi
        
        agent_name=$(basename "$agent_dir")
        agent_type=$(detect_agent_type "$agent_dir")
        agent_state_dir="$HOME/.openclaw/agents/$agent_name"
        
        echo "  📦 $agent_name (类型: $agent_type)"
        
        case "$agent_type" in
            functional)
                echo "      └─ 功能型：无需记忆系统"
                ;;
            
            operational)
                echo "      └─ 职能型：文件系统记忆"
                
                # 创建 memory 目录
                if [ ! -d "$agent_dir/memory" ]; then
                    mkdir -p "$agent_dir/memory"
                    echo "         ✅ 创建 memory/"
                fi
                
                # 禁用 memory-lancedb-pro
                if [ "$layer2a_installed" = true ]; then
                    mkdir -p "$agent_state_dir/agent"
                    cat > "$agent_state_dir/agent/openclaw.json" << 'AGENT_EOF'
{
  "plugins": {
    "entries": {
      "memory-lancedb-pro": {
        "enabled": false
      }
    }
  }
}
AGENT_EOF
                    echo "         ✅ 禁用 memory-lancedb-pro"
                fi
                ;;
            
            independent)
                echo "      └─ 独立人格型：完整记忆系统"
                
                # 创建完整 memory 结构
                if [ ! -d "$agent_dir/memory/topics" ]; then
                    mkdir -p "$agent_dir/memory/topics"
                    echo "         ✅ 创建 memory/topics/"
                fi
                
                if [ ! -d "$agent_dir/memory/runtime-maintenance" ]; then
                    mkdir -p "$agent_dir/memory/runtime-maintenance"
                    echo "         ✅ 创建 memory/runtime-maintenance/"
                fi
                
                # 启用 memory-lancedb-pro
                if [ "$layer2a_installed" = true ]; then
                    mkdir -p "$agent_state_dir/agent"
                    cat > "$agent_state_dir/agent/openclaw.json" << AGENT_EOF
{
  "plugins": {
    "entries": {
      "memory-lancedb-pro": {
        "enabled": true,
        "config": {
          "embedding": {
            "provider": "openai-compatible",
            "apiKey": "ollama",
            "baseURL": "http://127.0.0.1:11434/v1",
            "model": "bge-m3",
            "dimensions": 1024,
            "chunking": true,
            "taskQuery": "retrieval.query",
            "taskPassage": "retrieval.passage",
            "normalized": true
          },
          "dbPath": "~/.openclaw/agents/$agent_name/memory/lancedb-pro"
        }
      }
    }
  }
}
AGENT_EOF
                    echo "         ✅ 启用 memory-lancedb-pro"
                fi
                
                # 创建 MEMORY.md（如果不存在）
                if [ ! -f "$agent_dir/MEMORY.md" ]; then
                    cat > "$agent_dir/MEMORY.md" << 'MEMORY_EOF'
# MEMORY.md

> **本文件是索引**，详细内容在 `memory/topics/*.md` 主题文件中。

---

## ⚠️ 血泪教训（索引）

（待添加）

---

## ✅ 验证有效的做法

（待添加）

---

**最后更新**：$(date +%Y-%m-%d)
MEMORY_EOF
                    echo "         ✅ 创建 MEMORY.md"
                fi
                ;;
        esac
        
        echo ""
    done
fi

# 7. 生成优化报告
echo "=== 优化完成 ==="
echo ""
echo "📊 记忆架构状态:"
echo "  - Layer 1 (本地文件): ✅ 已优化"
echo "  - Layer 2A (memory-lancedb-pro): $([ "$layer2a_installed" = true ] && echo '✅ 已配置' || echo '❌ 未安装')"
echo "  - Layer 2B (lossless-claw-enhanced): $([ "$layer2b_installed" = true ] && echo '✅ 已安装' || echo '❌ 未安装')"
echo ""

echo "💡 使用建议:"
if [ "$layer2a_installed" = true ]; then
    echo "  - 使用 memory_store 保存重要记忆"
    echo "  - 使用 memory_recall 检索历史记忆"
fi
if [ "$layer2b_installed" = true ]; then
    echo "  - 使用 lcm_grep 搜索压缩的上下文"
    echo "  - 使用 lcm_expand_query 深度检索"
fi
echo ""

echo "📋 Agent 记忆配置:"
echo "  - 功能型 (functional): 无记忆系统"
echo "  - 职能型 (operational): 文件系统记忆（禁用 memory-lancedb-pro）"
echo "  - 独立人格型 (independent): 完整记忆系统（启用 memory-lancedb-pro）"
echo ""

echo "✅ 记忆架构优化完成"
echo ""
echo "💡 下一步："
echo "   1. 重启 gateway: openclaw gateway restart"
echo "   2. 验证配置: openclaw plugins info memory-lancedb-pro"
