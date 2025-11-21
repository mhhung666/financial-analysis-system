#!/bin/bash

# 每日市場分析腳本 - 使用 Claude CLI 分析當日市場資料
# 作者: Financial Analysis System
# 用途: 自動讀取當日指數、股價、新聞，調用 Claude 生成市場分析報告

set -e

# ==================== 設定區 ====================

# 確保 ~/.local/bin 在 PATH 中（Claude CLI 通常安裝在這裡）
export PATH="$HOME/.local/bin:$PATH"

# 獲取當前日期
TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y)

# 資料路徑
DAILY_DIR="data/market-data/${YEAR}/Daily"
NEWS_DIR="data/market-data/${YEAR}/News"
ANALYSIS_DIR="analysis/market"

# 檔案路徑
GLOBAL_INDICES_FILE="${DAILY_DIR}/global-indices-${TODAY}.md"
PRICES_FILE="${DAILY_DIR}/prices-${TODAY}.md"
ANALYSIS_OUTPUT="${ANALYSIS_DIR}/${TODAY}.md"

# Claude CLI 命令（優先使用完整路徑）
if [ -f "$HOME/.local/bin/claude" ]; then
    CLAUDE_CMD="$HOME/.local/bin/claude"
elif command -v claude &> /dev/null; then
    CLAUDE_CMD="claude"
else
    CLAUDE_CMD="claude"  # 如果找不到，仍然嘗試使用 claude
fi

# ==================== 檢查函數 ====================

check_claude_installed() {
    if ! command -v ${CLAUDE_CMD} &> /dev/null; then
        echo "❌ 錯誤: Claude CLI 未安裝"
        echo "請安裝 Claude CLI: https://github.com/anthropics/claude-cli"
        echo "或執行: npm install -g @anthropic-ai/claude-cli"
        exit 1
    fi
}

check_data_files() {
    local missing_files=()

    if [ ! -f "${GLOBAL_INDICES_FILE}" ]; then
        missing_files+=("全球指數檔案: ${GLOBAL_INDICES_FILE}")
    fi

    if [ ! -f "${PRICES_FILE}" ]; then
        missing_files+=("持倉價格檔案: ${PRICES_FILE}")
    fi

    if [ ${#missing_files[@]} -gt 0 ]; then
        echo "⚠️  警告: 以下資料檔案不存在："
        for file in "${missing_files[@]}"; do
            echo "  - ${file}"
        done
        echo ""
        echo "請先執行 'make fetch-daily' 和 'make holdings-prices-daily'"
        exit 1
    fi
}

check_analysis_dir() {
    if [ ! -d "${ANALYSIS_DIR}" ]; then
        echo "📁 創建分析目錄: ${ANALYSIS_DIR}"
        mkdir -p "${ANALYSIS_DIR}"
    fi
}

# ==================== 資料收集函數 ====================

collect_news_files() {
    echo "📰 收集當日新聞檔案..." >&2

    local news_files=()
    for news_file in "${NEWS_DIR}"/*-${TODAY}.md; do
        if [ -f "$news_file" ]; then
            news_files+=("$news_file")
        fi
    done

    echo "   找到 ${#news_files[@]} 個新聞檔案" >&2
    printf '%s\n' "${news_files[@]}"
}

# ==================== Claude 提示詞生成 ====================

generate_analysis_prompt() {
    local news_files=("$@")

    cat << 'EOF'
你是一位專業的金融市場分析師。請根據以下資料，生成一份完整的每日市場分析報告。

## 分析要求

1. **全球市場總覽**
   - 分析各主要市場（美國、亞洲、歐洲）的表現
   - 識別市場趨勢和關鍵驅動因素
   - 標記顯著的漲跌幅

2. **持倉股票分析**
   - 分析每支持股的當日表現
   - 結合新聞解讀股價變動原因
   - 提供持倉建議（持有/減碼/加碼）

3. **重要新聞解讀**
   - 深度分析影響市場的重大新聞
   - 評估新聞對持倉股票的影響
   - 識別投資機會和風險

4. **風險與機會**
   - VIX 恐慌指數分析
   - 商品市場（黃金、原油、比特幣）
   - 債券市場動態

5. **投資策略建議**
   - 基於當日市場表現的短期策略
   - 風險警示
   - 後市展望

## 報告格式

請使用 Markdown 格式，包含：
- 標題：# 📈 市場分析報告 - YYYY-MM-DD
- 清晰的分節與表格
- 使用 emoji 增強可讀性
- 結構化的持倉股票評級
- 風險等級評估

## 資料來源

### 全球指數資料
EOF

    # 插入全球指數資料
    echo '```markdown'
    cat "${GLOBAL_INDICES_FILE}"
    echo '```'
    echo ""

    # 插入持倉價格資料
    cat << 'EOF'

### 持倉股票價格
```markdown
EOF
    cat "${PRICES_FILE}"
    echo '```'
    echo ""

    # 插入新聞資料
    if [ ${#news_files[@]} -gt 0 ]; then
        cat << 'EOF'

### 個股新聞資料
EOF
        for news_file in "${news_files[@]}"; do
            local symbol=$(basename "$news_file" | sed "s/-${TODAY}.md//")
            echo ""
            echo "#### ${symbol} 新聞"
            echo '```markdown'
            cat "$news_file"
            echo '```'
        done
    fi

    cat << 'EOF'

---

請基於以上資料，生成完整、專業、深入的市場分析報告。
EOF
}

# ==================== 主要流程 ====================

main() {
    echo "================================================"
    echo "📊 每日市場分析系統"
    echo "================================================"
    echo ""
    echo "📅 分析日期: ${TODAY}"
    echo ""

    # 1. 檢查 Claude CLI
    echo "🔍 檢查 Claude CLI..."
    check_claude_installed
    echo "   ✅ Claude CLI 已安裝"
    echo ""

    # 2. 檢查資料檔案
    echo "🔍 檢查資料檔案..."
    check_data_files
    echo "   ✅ 資料檔案完整"
    echo ""

    # 3. 檢查/創建分析目錄
    check_analysis_dir
    echo ""

    # 4. 收集新聞檔案
    news_files=($(collect_news_files))
    echo ""

    # 5. 生成分析提示詞
    echo "🤖 生成 Claude 分析提示詞..."
    prompt=$(generate_analysis_prompt "${news_files[@]}")
    echo "   ✅ 提示詞已生成"
    echo ""

    # 6. 調用 Claude 進行分析
    echo "🧠 調用 Claude 進行市場分析..."
    echo "   這可能需要幾分鐘，請稍候..."
    echo ""

    # 使用 Claude CLI 進行分析並保存結果
    echo "${prompt}" | ${CLAUDE_CMD} > "${ANALYSIS_OUTPUT}"

    if [ $? -eq 0 ]; then
        echo "   ✅ 分析完成！"
        echo ""
        echo "================================================"
        echo "📄 分析報告已保存至:"
        echo "   ${ANALYSIS_OUTPUT}"
        echo "================================================"
        echo ""

        # 顯示報告摘要（前 50 行）
        echo "📋 報告摘要預覽："
        echo "------------------------------------------------"
        # 使用 sed 讀取前 50 行（兼容性更好）
        sed -n '1,50p' "${ANALYSIS_OUTPUT}"
        echo "------------------------------------------------"
        echo ""
        echo "💡 查看完整報告: cat ${ANALYSIS_OUTPUT}"
    else
        echo "   ❌ 分析失敗"
        exit 1
    fi
}

# 執行主程式
main
