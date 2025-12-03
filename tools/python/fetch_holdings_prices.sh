#!/bin/bash
#
# 持倉股票價格獲取腳本
#
# 功能：
# 從當年 portfolio/<year>/holdings.md 中提取股票代碼，並獲取當天的價格資訊
#
# 用法：
#   ./tools/python/fetch_holdings_prices.sh [選項]
#   或者
#   make holdings-prices
#
# 輸出：
#   - 價格資訊：螢幕輸出 + 可選儲存到 data/market-data/<year>/Daily/prices-YYYY-MM-DD.md
#

# 設定顏色輸出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
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

選項:
  -s, --save        儲存價格結果到 data/market-data/<year>/Daily/prices-YYYY-MM-DD.md（預設已啟用）
  --no-save         不儲存價格結果，僅顯示到螢幕
  -v, --verbose     顯示詳細資訊
  -h, --help        顯示此幫助資訊

範例:
  # 預設只爬價格，會自動儲存到 data/market-data/<year>/Daily/prices-YYYY-MM-DD.md
  ./tools/python/fetch_holdings_prices.sh

  # 僅顯示價格到螢幕，不儲存
  ./tools/python/fetch_holdings_prices.sh --no-save

說明:
  - 股票代碼從 portfolio/<year>/holdings.md 自動提取
EOF
    exit 0
fi

# 解析參數
SAVE_OUTPUT=true  # 預設自動儲存
VERBOSE=false

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

exit $EXIT_CODE
