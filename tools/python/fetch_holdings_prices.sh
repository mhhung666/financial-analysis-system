#!/bin/bash
#
# 持倉股票價格與新聞獲取腳本
#
# 功能：
# 1. 從當年 portfolio/<year>/holdings.md 中提取股票代碼，並獲取當天的價格資訊
# 2. 批次爬取所有持股的最新新聞（基於 config/holdings.yaml）
#
# 用法：
#   ./tools/python/fetch_holdings_prices.sh [選項]
#   或者
#   make holdings-prices
#
# 輸出：
#   - 價格資訊：螢幕輸出 + 可選儲存到 data/market-data/<year>/Daily/prices-YYYY-MM-DD.md
#   - 新聞資料：data/market-data/<year>/News/SYMBOL-YYYY-MM-DD.md
#

# 設定顏色輸出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 獲取腳本所在目錄
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 顯示幫助
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'EOF'
用法: ./tools/python/fetch_holdings_prices.sh [選項]

功能:
  1. 從 portfolio/<year>/holdings.md 中提取股票代碼
  2. 獲取每隻股票的當天價格資訊
  3. 批次爬取持股的最新新聞（可選）

選項:
  -s, --save        儲存價格結果到 data/market-data/<year>/Daily/prices-YYYY-MM-DD.md（預設已啟用）
  --no-save         不儲存價格結果，僅顯示到螢幕
  -v, --verbose     顯示詳細資訊
  -n, --news        同時爬取所有持股的最新新聞
  -h, --help        顯示此幫助資訊

範例:
  # 預設只爬價格，會自動儲存到 data/market-data/<year>/Daily/prices-YYYY-MM-DD.md
  ./tools/python/fetch_holdings_prices.sh

  # 同時爬取價格和新聞
  ./tools/python/fetch_holdings_prices.sh --news

  # 僅顯示價格到螢幕，不儲存
  ./tools/python/fetch_holdings_prices.sh --no-save

  # 顯示詳細資訊 + 爬取新聞
  ./tools/python/fetch_holdings_prices.sh --verbose --news

說明:
  - 股票代碼從 portfolio/<year>/holdings.md 自動提取
  - 新聞輸出: data/market-data/<year>/News/SYMBOL-YYYY-MM-DD.md
EOF
    exit 0
fi

# 解析參數
SAVE_OUTPUT=true  # 預設自動儲存
VERBOSE=false
FETCH_NEWS=false  # 預設不爬新聞

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--save)
            SAVE_OUTPUT=true
            shift
            ;;
        --no-save)
            SAVE_OUTPUT=false
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -n|--news)
            FETCH_NEWS=true
            shift
            ;;
        *)
            echo "未知選項: $1"
            echo "使用 -h 或 --help 檢視幫助"
            exit 1
            ;;
    esac
done

# Python 腳本路徑
SCRAPER="$SCRIPT_DIR/scrapers/fetch_holdings_prices.py"

# 當年年份
CURRENT_YEAR=$(date +%Y)

# Holdings 檔案路徑
HOLDINGS_FILE="$PROJECT_ROOT/portfolio/$CURRENT_YEAR/holdings.md"

# 檢查 holdings 檔案是否存在
if [ ! -f "$HOLDINGS_FILE" ]; then
    echo -e "\033[0;31m錯誤: 找不到 holdings 檔案: $HOLDINGS_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}持倉股票價格分析${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Holdings 檔案: ${GREEN}$HOLDINGS_FILE${NC}"
echo ""

# 建構 Python 命令
CMD="python3 \"$SCRAPER\" -i \"$HOLDINGS_FILE\""

if [ "$VERBOSE" = true ]; then
    CMD="$CMD -v"
fi

# 產生帶日期的輸出檔案名
TODAY=$(date +%Y-%m-%d)
OUTPUT_DIR="$PROJECT_ROOT/data/market-data/$CURRENT_YEAR/Daily"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/prices-$TODAY.md"

if [ "$SAVE_OUTPUT" = true ]; then
    CMD="$CMD -o \"$OUTPUT_FILE\""
    echo -e "輸出檔案: ${GREEN}$OUTPUT_FILE${NC}"
    echo ""
fi

# 執行 Python 腳本
eval $CMD

EXIT_CODE=$?

echo ""
echo -e "${BLUE}========================================${NC}"

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ 價格資料完成！${NC}"

    if [ "$SAVE_OUTPUT" = true ]; then
        echo ""
        echo -e "價格資訊已儲存到:"
        echo -e "  ${GREEN}$OUTPUT_FILE${NC}"
    fi
else
    echo -e "\033[0;31m✗ 價格資料執行失敗${NC}"
fi

echo -e "${BLUE}========================================${NC}"

# ============================================
# 第二步：爬取持股新聞（如果有 --news 參數）
# ============================================
if [ "$FETCH_NEWS" = true ]; then
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}第二步：爬取持股新聞${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    # Python 新聞爬蟲腳本路徑
    NEWS_SCRAPER="$SCRIPT_DIR/scrapers/fetch_market_news.py"

    # 取得當前年份
    CURRENT_YEAR=$(date +%Y)

    # 設定輸出目錄（動態年份）
    NEWS_DIR="$PROJECT_ROOT/data/market-data/$CURRENT_YEAR/News"
    mkdir -p "$NEWS_DIR"

    echo -e "Holdings 檔案: ${GREEN}$HOLDINGS_FILE${NC}"
    echo -e "新聞輸出: ${GREEN}$NEWS_DIR${NC}"
    echo ""

    # 從 holdings.md 提取股票代碼
    # 使用 Python 解析 Markdown 表格並輸出格式: "symbol|name"
    HOLDINGS_LIST=$(python3 -c "
import re
import sys

try:
    with open('$HOLDINGS_FILE', 'r', encoding='utf-8') as f:
        content = f.read()

    # 使用正則表達式從表格中提取股票代碼和名稱
    # 匹配格式: | U | Unity Software | ... (第一列是代碼，第二列是公司名稱)
    pattern = r'\|\s*([A-Z][A-Z0-9.]*)\s*\|\s*([^|]+?)\s*\|'
    matches = re.findall(pattern, content)

    holdings = []
    seen = set()
    for symbol, name in matches:
        # 過濾掉表頭和一些非股票代碼的行
        if symbol in ['股票代碼', '代碼', 'Symbol', '項目', '日期']:
            continue
        # 避免重複
        if symbol in seen:
            continue
        seen.add(symbol)
        # 清理公司名稱
        name = name.strip()
        holdings.append(f'{symbol}|{name}')

    for item in holdings:
        print(item)
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
" 2>&1)

    # 檢查是否成功讀取持股
    if [ $? -ne 0 ]; then
        echo -e "\033[0;31m✗ 無法讀取 holdings 檔案: $HOLDINGS_FILE${NC}"
        echo "$HOLDINGS_LIST"
        exit 1
    fi

    # 將 Python 輸出轉換為陣列 (使用兼容的方式)
    IFS=$'\n' read -r -d '' -a HOLDINGS_ARRAY <<< "$HOLDINGS_LIST" || true

    # 如果沒有找到股票代碼，跳過
    if [ ${#HOLDINGS_ARRAY[@]} -eq 0 ] || [ -z "${HOLDINGS_ARRAY[0]}" ]; then
        echo -e "${YELLOW}⚠ 無法從 holdings.md 中提取股票代碼${NC}"
        NEWS_TOTAL=0
        NEWS_SUCCESS=0
        NEWS_FAILED=0
    else
        # 計數器
        NEWS_TOTAL=${#HOLDINGS_ARRAY[@]}
        NEWS_SUCCESS=0
        NEWS_FAILED=0

        echo -e "${BLUE}開始爬取 $NEWS_TOTAL 支股票的新聞...${NC}"
        echo ""

        # 爬取每個持股的新聞
        for item in "${HOLDINGS_ARRAY[@]}"; do
            IFS='|' read -r symbol name <<< "$item"

            echo -e "${YELLOW}正在爬取: $name ($symbol)${NC}"

            # 不再指定 -o 參數，讓爬蟲自動產生帶日期的檔名
            if python3 "$NEWS_SCRAPER" "$symbol" 2>/dev/null; then
                echo -e "${GREEN}✓ $name 完成${NC}"
                ((NEWS_SUCCESS++))
            else
                echo -e "\033[0;31m✗ $name 失敗${NC}"
                ((NEWS_FAILED++))
            fi
            echo ""
        done
    fi

    # 顯示新聞統計資訊
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}新聞爬取總結${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "【持股新聞】"
    echo "  總共: $NEWS_TOTAL 支股票"
    echo -e "  成功: ${GREEN}$NEWS_SUCCESS${NC}"
    if [ $NEWS_FAILED -gt 0 ]; then
        echo -e "  失敗: \033[0;31m$NEWS_FAILED${NC}"
    else
        echo -e "  失敗: $NEWS_FAILED"
    fi
    echo ""

    # 列出生成的檔案
    echo "【生成的新聞檔案】"
    TODAY_DATE=$(date +%Y-%m-%d)
    if ls -lh "$NEWS_DIR"/*-$TODAY_DATE.md 2>/dev/null | head -5; then
        FILE_COUNT=$(ls "$NEWS_DIR"/*-$TODAY_DATE.md 2>/dev/null | wc -l)
        if [ $FILE_COUNT -gt 5 ]; then
            echo "  ... 以及其他 $((FILE_COUNT - 5)) 個檔案"
        fi
    else
        echo "  (無檔案生成)"
    fi
    echo ""
    echo -e "新聞資料路徑: ${GREEN}$NEWS_DIR${NC}"
    echo -e "${BLUE}========================================${NC}"
fi

exit $EXIT_CODE
