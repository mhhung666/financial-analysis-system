#!/bin/bash

# 每周市場分析腳本 - 使用 Claude CLI 分析每周市場資料
# 作者: Financial Analysis System
# 用途: 自動讀取本周指數、股價、新聞，調用 Claude 生成每周市場分析報告

set -e

# ==================== 設定區 ====================

# 確保 ~/.local/bin 在 PATH 中（Claude CLI 通常安裝在這裡）
export PATH="$HOME/.local/bin:$PATH"

# 獲取前一週的日期範圍
# 週一為一週的開始，分析上週一到上週日
WEEK_START=$(date -d "monday last week" +%Y-%m-%d 2>/dev/null || date -v-Mon-7d +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)
WEEK_END=$(date -d "sunday last week" +%Y-%m-%d 2>/dev/null || date -v-Sun-0d +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)
TODAY=$(date +%Y-%m-%d)
YEAR=$(date -d "$WEEK_START" +%Y 2>/dev/null || date -j -f "%Y-%m-%d" "$WEEK_START" +%Y 2>/dev/null || date +%Y)
# 使用週一的日期計算週數
WEEK_NUMBER=$(date -d "$WEEK_START" +%Y-W%V 2>/dev/null || date -j -f "%Y-%m-%d" "$WEEK_START" +%Y-W%V 2>/dev/null || date +%Y-W%V)

# 資料路徑
DAILY_DIR="data/market-data/${YEAR}/Daily"
NEWS_DIR="data/market-data/${YEAR}/News"
DAILY_ANALYSIS_DIR="analysis/market"
WEEKLY_ANALYSIS_DIR="analysis/market/weekly"

# 檔案路徑
ANALYSIS_OUTPUT="${WEEKLY_ANALYSIS_DIR}/weekly-${WEEK_NUMBER}.md"

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

check_analysis_dir() {
    if [ ! -d "${WEEKLY_ANALYSIS_DIR}" ]; then
        echo "📁 創建每周分析目錄: ${WEEKLY_ANALYSIS_DIR}"
        mkdir -p "${WEEKLY_ANALYSIS_DIR}"
    fi
}

# ==================== 資料收集函數 ====================

collect_daily_analysis_files() {
    echo "📊 收集本週每日分析報告..." >&2

    local daily_files=()
    local current_date=$WEEK_START

    # 遍歷本週的每一天
    while [ "$current_date" != "$(date -d "$WEEK_END + 1 day" +%Y-%m-%d 2>/dev/null || date -v+1d -j -f "%Y-%m-%d" "$WEEK_END" +%Y-%m-%d 2>/dev/null)" ]; do
        local daily_file="${DAILY_ANALYSIS_DIR}/${current_date}.md"
        if [ -f "$daily_file" ]; then
            daily_files+=("$daily_file")
        fi
        current_date=$(date -d "$current_date + 1 day" +%Y-%m-%d 2>/dev/null || date -v+1d -j -f "%Y-%m-%d" "$current_date" +%Y-%m-%d 2>/dev/null)
    done

    echo "   找到 ${#daily_files[@]} 個每日分析檔案" >&2
    printf '%s\n' "${daily_files[@]}"
}

collect_weekly_data_files() {
    echo "📰 收集本週資料檔案..." >&2

    local data_files=()
    local current_date=$WEEK_START

    # 遍歷本週的每一天，收集全球指數和持倉價格資料
    while [ "$current_date" != "$(date -d "$WEEK_END + 1 day" +%Y-%m-%d 2>/dev/null || date -v+1d -j -f "%Y-%m-%d" "$WEEK_END" +%Y-%m-%d 2>/dev/null)" ]; do
        local indices_file="${DAILY_DIR}/global-indices-${current_date}.md"
        local prices_file="${DAILY_DIR}/prices-${current_date}.md"

        if [ -f "$indices_file" ]; then
            data_files+=("$indices_file")
        fi
        if [ -f "$prices_file" ]; then
            data_files+=("$prices_file")
        fi

        current_date=$(date -d "$current_date + 1 day" +%Y-%m-%d 2>/dev/null || date -v+1d -j -f "%Y-%m-%d" "$current_date" +%Y-%m-%d 2>/dev/null)
    done

    echo "   找到 ${#data_files[@]} 個資料檔案" >&2
    printf '%s\n' "${data_files[@]}"
}

get_reference_report() {
    echo "📚 查找參考範例報告..." >&2

    # 查找最近的一份每周分析報告作為格式參考
    local reference_file=$(ls -t "${WEEKLY_ANALYSIS_DIR}"/weekly-*.md 2>/dev/null | head -n 1)

    if [ -f "$reference_file" ]; then
        echo "   找到參考報告: $(basename "$reference_file")" >&2
        cat "$reference_file"
    else
        echo "   未找到參考報告，使用每日報告作為參考" >&2
        # 如果沒有每周報告，使用最近的每日報告作為參考
        local daily_reference=$(ls -t "${DAILY_ANALYSIS_DIR}"/*.md 2>/dev/null | head -n 1)
        if [ -f "$daily_reference" ]; then
            cat "$daily_reference"
        else
            echo ""
        fi
    fi
}

# ==================== Claude 提示詞生成 ====================

generate_weekly_prompt() {
    local daily_files=("$@")

    cat << 'EOF'
你是一位專業的金融市場分析師。請根據**上週**（前一週）的每日分析報告和市場資料，生成一份完整的每周市場分析報告。

## 📋 重要指示

**這是一份每周報告，需要總結上週的市場表現、整體氛圍、趨勢變化和重要事件。**
**重點是整理和總結上週的市場氛圍，而不是預測未來。**

## 分析要求

1. **上週市場總覽**
   - 總結上週各主要市場（美國、亞洲、歐洲）的整體表現
   - 識別上週的主要市場趨勢和轉折點
   - 分析週內的重大事件及其影響
   - 比較週初與週末的市場變化
   - 使用表格呈現週度數據（週初、週末、週漲跌幅）
   - **捕捉上週的整體市場氛圍**（樂觀/悲觀/震盪/觀望等）

2. **持倉股票週度分析**
   - 分析每支持股上週的整體表現
   - 識別上週表現最佳和最差的股票
   - 總結影響個股表現的關鍵因素
   - 評估持倉組合的整體風險敞口

3. **重要事件回顧**
   - 深度分析上週影響市場的重大新聞和事件
   - 評估這些事件對市場和持倉的影響
   - 分析市場情緒的變化軌跡
   - **總結上週市場對各類新聞的反應模式**

4. **技術面與基本面週度回顧**
   - VIX 指數週度變化及市場恐慌程度
   - 商品市場（黃金、原油、比特幣）週度走勢
   - 債券市場動態變化
   - 關鍵技術指標的週度變化
   - 宏觀經濟數據及市場反應

5. **週度總結與啟示**
   - 總結上週市場的關鍵特徵和主導因素
   - 識別市場參與者的行為模式
   - 提煉上週市場給投資者的啟示
   - 評估上週風險事件的處理經驗

## 報告格式要求

請使用 Markdown 格式，建議包含以下結構：
- 標題：# 📊 每周市場分析報告 - 週次 (日期範圍)
- 包含報告生成時間和分析週期（上週）
- 執行摘要（上週重點和市場氛圍總結）
- 清晰的章節編號和分節
- 豐富的表格呈現週度數據對比
- 適當使用 emoji 增強可讀性
- 上週關鍵數據統計（漲跌幅、波動率、成交量等）
- 圖表化的趨勢分析（使用 Markdown 表格呈現）
- **市場氛圍總結**（投資者情緒、市場風格、資金流向等）
- 上週經驗總結和啟示
- 免責聲明

## 參考範例報告（格式參考）
EOF

    # 插入參考報告
    local reference_content=$(get_reference_report)
    if [ -n "$reference_content" ]; then
        echo ""
        echo '```markdown'
        # 只顯示前 200 行作為參考
        echo "$reference_content" | head -n 200
        echo '```'
        echo ""
    fi

    cat << EOF

## 本週資料來源

### 分析週期
- **週次**: ${WEEK_NUMBER}
- **日期範圍**: ${WEEK_START} 至 ${WEEK_END}
- **分析生成日期**: ${TODAY}

### 本週每日分析報告
EOF

    # 插入每日分析報告
    if [ ${#daily_files[@]} -gt 0 ]; then
        for daily_file in "${daily_files[@]}"; do
            local date=$(basename "$daily_file" .md)
            echo ""
            echo "#### ${date} 每日報告"
            echo '```markdown'
            cat "$daily_file"
            echo '```'
            echo ""
        done
    else
        echo ""
        echo "⚠️ 本週暫無每日分析報告"
        echo ""
    fi

    cat << 'EOF'

---

## 📝 輸出指示

**重要**: 請直接輸出完整的每周市場分析報告內容，不要詢問授權或確認。

要求:
1. 立即開始生成報告，從標題 "# 📊 每周市場分析報告" 開始
2. **總結上週市場的整體表現、關鍵趨勢和市場氛圍**
3. 包含所有章節：執行摘要、週度市場總覽、持倉週度分析、重要事件回顧、技術與基本面回顧、週度總結與啟示
4. 直接輸出 Markdown 格式的報告內容，不要有任何前置說明或詢問
5. 報告應該是完整的、可以直接保存為 .md 文件的內容
6. **重點分析週度變化趨勢和市場氛圍，而不僅僅是羅列每日數據**
7. **著重於回顧和總結上週的市場表現，捕捉市場情緒和投資者行為**

現在請生成完整的每周市場分析報告:
EOF
}

# ==================== 主要流程 ====================

main() {
    echo "================================================"
    echo "📊 每周市場分析系統"
    echo "================================================"
    echo ""
    echo "📅 分析週次: ${WEEK_NUMBER}"
    echo "📅 日期範圍: ${WEEK_START} 至 ${WEEK_END}"
    echo ""

    # 1. 檢查 Claude CLI
    echo "🔍 檢查 Claude CLI..."
    check_claude_installed
    echo "   ✅ Claude CLI 已安裝"
    echo ""

    # 2. 檢查/創建分析目錄
    check_analysis_dir
    echo ""

    # 3. 收集每日分析檔案
    daily_files=($(collect_daily_analysis_files))

    if [ ${#daily_files[@]} -eq 0 ]; then
        echo "⚠️  警告: 上週沒有找到任何每日分析報告"
        echo "日期範圍: ${WEEK_START} 至 ${WEEK_END}"
        echo "建議先為上週的每一天執行 'make analyze-daily' 生成每日報告"
        echo ""
        read -p "是否繼續生成每周報告？(y/N): " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "取消每周分析"
            exit 0
        fi
    fi
    echo ""

    # 4. 收集週度資料檔案（供參考）
    data_files=($(collect_weekly_data_files))
    echo ""

    # 5. 生成分析提示詞
    echo "🤖 生成 Claude 分析提示詞..."
    prompt=$(generate_weekly_prompt "${daily_files[@]}")
    echo "   ✅ 提示詞已生成"
    echo ""

    # 6. 調用 Claude 進行分析
    echo "🧠 調用 Claude 進行每周市場分析..."
    echo "   這可能需要幾分鐘，請稍候..."
    echo ""

    # 使用 Claude CLI 進行分析並保存結果
    echo "${prompt}" | ${CLAUDE_CMD} > "${ANALYSIS_OUTPUT}"

    if [ $? -eq 0 ]; then
        echo "   ✅ 分析完成！"
        echo ""
        echo "================================================"
        echo "📄 每周分析報告已保存至:"
        echo "   ${ANALYSIS_OUTPUT}"
        echo "================================================"
        echo ""

        # 顯示報告摘要（前 50 行）
        echo "📋 報告摘要預覽："
        echo "------------------------------------------------"
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
