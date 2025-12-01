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

get_reference_report() {
    echo "📚 查找參考範例報告..." >&2

    # 查找最近的一份分析報告作為格式參考
    local reference_file=$(ls -t "${ANALYSIS_DIR}"/*.md 2>/dev/null | head -n 1)

    if [ -f "$reference_file" ]; then
        echo "   找到參考報告: $(basename "$reference_file")" >&2
        cat "$reference_file"
    else
        echo "   未找到參考報告，使用預設格式" >&2
        echo ""
    fi
}

# ==================== Claude 提示詞生成 ====================

get_template_structure() {
    echo "📚 讀取報告結構模板..." >&2

    local template_file="templates/analysis/market-daily-article-template.md"

    if [ -f "$template_file" ]; then
        echo "   找到模板: $(basename "$template_file")" >&2
        cat "$template_file"
    else
        echo "   未找到模板,使用預設格式" >&2
        echo ""
    fi
}

generate_analysis_prompt() {
    local news_files=("$@")

    cat << 'EOF'
你是一位專業的金融市場分析師。請根據以下資料，生成一份完整的每日市場分析報告。

## 📋 核心要求

**本報告必須是自然流暢的文章式風格,同時嚴格遵循提供的報告結構模板。**

### 關鍵原則:
1. **結構一致性**: 嚴格按照「報告結構模板」的章節順序和架構撰寫
2. **文章風格**: 用自然、專業的敘述方式,避免冷冰冰的數據堆砌
3. **深度分析**: 提供洞見和判斷,而非僅僅轉述數據
4. **可讀性**: 適當使用表格呈現關鍵數據,但分析要融入文字敘述中

### 寫作風格要求:
- ✅ 用完整的句子和段落,展現分析思路
- ✅ 適當使用過渡詞,讓內容流暢連貫
- ✅ 數據要服務於分析,而非為數據而數據
- ✅ 提供「為什麼」的解釋,而非只有「是什麼」的描述
- ✅ 專業但易懂,避免過於學術或過於口語
- ❌ 不要機械式列點
- ❌ 不要冷冰冰的條列式結構
- ❌ 不要像填表格一樣填寫模板

### 具體要求:

1. **執行摘要**:
   - 用2-3段流暢的文字總結市場,展現分析思路
   - 關鍵數據用表格呈現
   - 風險評估要有邏輯和依據

2. **全球市場總覽**:
   - 主要指數用表格
   - 市場分析用完整段落敘述,解釋趨勢和原因
   - 突出重點,有主次之分

3. **持倉股票分析**:
   - 這是報告最重要的部分
   - 每支股票提供深入分析,結合新聞、基本面、技術面
   - 持倉建議要具體、有依據、可執行

4. **重要新聞解讀**:
   - 深度分析,而非轉述
   - 解釋新聞背後的邏輯和影響
   - 連結到投資決策

5. **投資策略**:
   - 提供具體、可執行的建議
   - 說明理由和條件
   - 包含觸發式指令

## 報告結構模板

以下是報告的標準結構,請嚴格遵循所有章節和順序:

EOF

    # 插入結構模板
    local template_content=$(get_template_structure)
    if [ -n "$template_content" ]; then
        echo ""
        echo '```markdown'
        echo "$template_content"
        echo '```'
        echo ""
    fi

    cat << 'EOF'

## 參考範例報告

以下是一份優秀的報告範例,展示了如何將結構化要求與文章式風格完美結合:

EOF

    # 插入參考報告
    local reference_content=$(get_reference_report)
    if [ -n "$reference_content" ]; then
        echo ""
        echo '```markdown'
        echo "$reference_content"
        echo '```'
        echo ""
    fi

    cat << 'EOF'

## 今日資料來源

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

## 📝 輸出指示

**重要**: 請直接輸出完整的市場分析報告內容,不要詢問授權或確認。

要求:
1. 立即開始生成報告,從標題 "# 📈 市場分析報告 - YYYY-MM-DD" 開始
2. 嚴格遵循參考範例的格式和結構
3. 包含所有章節:執行摘要、全球市場、持倉分析、新聞解讀、風險機會、投資策略、後市展望、監控指標、行動清單
4. 直接輸出 Markdown 格式的報告內容,不要有任何前置說明或詢問
5. 報告應該是完整的、可以直接保存為 .md 文件的內容

現在請生成完整的市場分析報告:
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
