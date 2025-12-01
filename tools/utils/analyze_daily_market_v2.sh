#!/bin/bash

# 每日市場分析腳本 V2 - 使用 YAML 模板格式
# 作者: Financial Analysis System
# 用途: 自動讀取當日指數、股價、新聞，調用 Claude 生成 YAML 格式的市場分析報告

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
TEMPLATE_DIR="templates/analysis"

# 檔案路徑
GLOBAL_INDICES_FILE="${DAILY_DIR}/global-indices-${TODAY}.md"
PRICES_FILE="${DAILY_DIR}/prices-${TODAY}.md"
ANALYSIS_OUTPUT_YAML="${ANALYSIS_DIR}/${TODAY}.yaml"
ANALYSIS_OUTPUT_MD="${ANALYSIS_DIR}/${TODAY}.md"
TEMPLATE_FILE="${TEMPLATE_DIR}/market-daily-template.yaml"
EXAMPLE_FILE="${TEMPLATE_DIR}/example-usage.yaml"

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

check_template_files() {
    if [ ! -f "${TEMPLATE_FILE}" ]; then
        echo "❌ 錯誤: 找不到 YAML 模板檔案: ${TEMPLATE_FILE}"
        exit 1
    fi

    if [ ! -f "${EXAMPLE_FILE}" ]; then
        echo "⚠️  警告: 找不到範例檔案: ${EXAMPLE_FILE}"
        echo "   將僅使用模板檔案作為參考"
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

generate_yaml_analysis_prompt() {
    local news_files=("$@")

    cat << 'EOF'
你是一位專業的金融市場分析師。請根據以下資料，生成一份結構化的 YAML 格式市場分析報告。

## 📋 重要指示

1. **使用 YAML 模板格式**: 嚴格按照提供的 YAML 模板結構生成報告
2. **參考範例檔案**: 參考 example-usage.yaml 了解如何填寫數據
3. **數據結構化**: 所有數據都應該是結構化的,方便程式處理
4. **保持一致性**: 欄位名稱和結構必須與模板完全一致

## YAML 模板結構

以下是您需要遵循的 YAML 模板結構:

```yaml
EOF

    # 插入模板檔案
    cat "${TEMPLATE_FILE}"

    cat << 'EOF'
```

## 範例參考

以下是填寫範例,展示如何將實際數據填入模板:

```yaml
EOF

    # 插入範例檔案（如果存在）
    if [ -f "${EXAMPLE_FILE}" ]; then
        cat "${EXAMPLE_FILE}"
    fi

    cat << 'EOF'
```

## 今日資料來源

### 全球指數資料

```markdown
EOF

    # 插入全球指數資料
    cat "${GLOBAL_INDICES_FILE}"

    cat << 'EOF'
```

### 持倉股票價格

```markdown
EOF

    # 插入持倉價格資料
    cat "${PRICES_FILE}"

    cat << 'EOF'
```
EOF

    # 插入新聞資料
    if [ ${#news_files[@]} -gt 0 ]; then
        cat << 'EOF'

### 個股新聞資料

EOF
        for news_file in "${news_files[@]}"; do
            local symbol=$(basename "$news_file" | sed "s/-${TODAY}.md//")
            echo ""
            echo "#### ${symbol} 新聞"
            echo ""
            echo '```markdown'
            cat "$news_file"
            echo '```'
        done
    fi

    cat << 'EOF'

---

## 📝 輸出指示

**重要要求**:

1. **直接輸出 YAML**: 立即開始生成 YAML 格式的報告,不要有任何前置說明
2. **完整結構**: 包含模板中的所有主要區塊:
   - metadata (報告元數據)
   - executive_summary (執行摘要)
   - global_markets (全球市場總覽)
   - portfolio_analysis (持倉股票分析)
   - news_analysis (重要新聞解讀)
   - risk_and_opportunity (風險評估與投資機會)
   - investment_strategy (投資策略建議)
   - outlook (後市展望)
   - monitoring_indicators (關鍵監控指標)
   - action_items (行動清單)
   - disclaimer (免責聲明)
   - report_metadata (報告元數據)

3. **數據準確性**:
   - 從提供的資料中提取準確的數值
   - 保持數值類型正確(數字用數值,不要加引號)
   - 百分比用小數表示(例如: 0.54 表示 0.54%)

4. **分析深度**:
   - 提供專業的市場分析和解讀
   - 給出具體的投資建議和操作策略
   - 包含風險評估和情境分析

5. **日期時間**:
   - report_date: 使用今天的日期 (YYYY-MM-DD 格式)
   - report_time_utc: 使用當前 UTC 時間 (HH:MM 格式)

6. **純 YAML 輸出**:
   - 不要在 YAML 前後加上 ```yaml 標記
   - 直接從第一行開始輸出 YAML 內容
   - 確保 YAML 格式正確,可以被解析器讀取

現在請生成完整的 YAML 格式市場分析報告:
EOF
}

# ==================== 後處理函數 ====================

post_process_yaml() {
    local yaml_file="$1"

    # 移除可能的 markdown 代碼塊標記
    sed -i.bak '/^```yaml$/d; /^```$/d' "$yaml_file"

    # 移除備份檔案
    rm -f "${yaml_file}.bak"
}

# ==================== 主要流程 ====================

main() {
    echo "================================================"
    echo "📊 每日市場分析系統 V2 (YAML 格式)"
    echo "================================================"
    echo ""
    echo "📅 分析日期: ${TODAY}"
    echo ""

    # 1. 檢查 Claude CLI
    echo "🔍 檢查 Claude CLI..."
    check_claude_installed
    echo "   ✅ Claude CLI 已安裝"
    echo ""

    # 2. 檢查模板檔案
    echo "🔍 檢查模板檔案..."
    check_template_files
    echo "   ✅ 模板檔案存在"
    echo ""

    # 3. 檢查資料檔案
    echo "🔍 檢查資料檔案..."
    check_data_files
    echo "   ✅ 資料檔案完整"
    echo ""

    # 4. 檢查/創建分析目錄
    check_analysis_dir
    echo ""

    # 5. 收集新聞檔案
    news_files=($(collect_news_files))
    echo ""

    # 6. 生成分析提示詞
    echo "🤖 生成 Claude 分析提示詞 (YAML 格式)..."
    prompt=$(generate_yaml_analysis_prompt "${news_files[@]}")
    echo "   ✅ 提示詞已生成"
    echo ""

    # 7. 調用 Claude 進行分析
    echo "🧠 調用 Claude 進行市場分析 (生成 YAML)..."
    echo "   這可能需要幾分鐘，請稍候..."
    echo ""

    # 使用 Claude CLI 進行分析並保存結果
    echo "${prompt}" | ${CLAUDE_CMD} > "${ANALYSIS_OUTPUT_YAML}"

    if [ $? -eq 0 ]; then
        echo "   ✅ YAML 分析完成！"
        echo ""

        # 後處理 YAML 檔案
        echo "🔧 後處理 YAML 檔案..."
        post_process_yaml "${ANALYSIS_OUTPUT_YAML}"
        echo "   ✅ YAML 格式化完成"
        echo ""

        echo "================================================"
        echo "📄 YAML 報告已保存至:"
        echo "   ${ANALYSIS_OUTPUT_YAML}"
        echo "================================================"
        echo ""

        # 顯示 YAML 摘要（前 50 行）
        echo "📋 YAML 報告摘要預覽："
        echo "------------------------------------------------"
        sed -n '1,50p' "${ANALYSIS_OUTPUT_YAML}"
        echo "------------------------------------------------"
        echo ""
        echo "💡 查看完整 YAML 報告: cat ${ANALYSIS_OUTPUT_YAML}"
        echo ""
        echo "📝 提示: 您可以使用 Python/Node.js 讀取此 YAML 檔案並轉換為 Markdown 格式"
    else
        echo "   ❌ 分析失敗"
        exit 1
    fi
}

# 執行主程式
main
