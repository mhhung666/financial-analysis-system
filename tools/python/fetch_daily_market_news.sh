#!/bin/bash
#
# 每日大盤市場資料與新聞爬蟲腳本
#
# 功能：
# 1. 爬取全球市場指數（日本、韓國、台灣、中國、新加坡、香港、歐洲、美國）
# 2. 爬取主要市場指數的最新新聞（S&P 500、NASDAQ、恆生、道瓊）
#
# 用法：
#   ./tools/python/fetch_daily_market_news.sh
#
# 輸出：
#   - 全球指數：data/market-data/YYYY/Daily/global-indices-YYYY-MM-DD.md
#   - 市場新聞：data/market-data/YYYY/News/SYMBOL-YYYY-MM-DD.md
#

# 設定顏色輸出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 取得腳本所在目錄
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 顯示說明
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'EOF'
用法: ./tools/python/fetch_daily_market_news.sh

功能:
  1. 產生全球市場指數檔案 data/market-data/{YEAR}/Daily/global-indices-YYYY-MM-DD.md
  2. 下載 S&P 500 / NASDAQ / 恆生 / 道瓊新聞 data/market-data/{YEAR}/News/SYMBOL-YYYY-MM-DD.md

說明:
  - 檔案會自動加上日期，確保每日快照不被覆蓋。
  - 若要只執行單一爬蟲，可改用 tools/python/scrapers/ 內的個別腳本。
EOF
    exit 0
fi

# 取得當前年份
CURRENT_YEAR=$(date +%Y)

# 設定輸出目錄（動態年份）
NEWS_DIR="$PROJECT_ROOT/data/market-data/$CURRENT_YEAR/News"
DAILY_DIR="$PROJECT_ROOT/data/market-data/$CURRENT_YEAR/Daily"
mkdir -p "$NEWS_DIR"
mkdir -p "$DAILY_DIR"

# Python 爬蟲腳本路徑
NEWS_SCRAPER="$SCRIPT_DIR/scrapers/fetch_market_news.py"
INDICES_SCRAPER="$SCRIPT_DIR/scrapers/fetch_global_indices.py"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}每日大盤市場資料與新聞爬蟲${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "新聞輸出: ${GREEN}$NEWS_DIR${NC}"
echo -e "指數輸出: ${GREEN}$DAILY_DIR${NC}"
echo ""

# ============================================
# 第一步：爬取全球市場指數
# ============================================
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}第一步：爬取全球市場指數${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if python3 "$INDICES_SCRAPER" 2>&1 | grep -v "正在爬取"; then
    echo -e "${GREEN}✓ 全球市場指數爬取完成${NC}"
    INDICES_SUCCESS=1
else
    echo -e "\033[0;31m✗ 全球市場指數爬取失敗${NC}"
    INDICES_SUCCESS=0
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}第二步：爬取市場新聞${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 從 YAML 配置讀取需要爬新聞的指數
# 使用 Python 解析 YAML 並輸出格式: "symbol|name"
CONFIG_FILE="$SCRIPT_DIR/config/indices.yaml"
NEWS_INDICES=$(python3 -c "
import yaml
import sys

try:
    with open('$CONFIG_FILE', 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)

    indices = []
    for region, region_data in config.get('global_indices', {}).items():
        for name, data in region_data.items():
            if isinstance(data, dict) and data.get('fetch_news', False):
                symbol = data.get('symbol', '')
                indices.append(f'{symbol}|{name}')

    for item in indices:
        print(item)
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
" 2>&1)

# 檢查是否成功讀取配置
if [ $? -ne 0 ]; then
    echo -e "\033[0;31m✗ 無法讀取配置文件: $CONFIG_FILE${NC}"
    echo "$NEWS_INDICES"
    exit 1
fi

# 將 Python 輸出轉換為陣列 (使用兼容的方式)
IFS=$'\n' read -r -d '' -a INDICES_ARRAY <<< "$NEWS_INDICES" || true

# 如果沒有需要爬新聞的指數，跳過
if [ ${#INDICES_ARRAY[@]} -eq 0 ] || [ -z "${INDICES_ARRAY[0]}" ]; then
    echo -e "${YELLOW}⚠ 配置文件中沒有設定 fetch_news: true 的指數${NC}"
    echo -e "${YELLOW}如需爬取新聞，請在 $CONFIG_FILE 中將對應指數的 fetch_news 設為 true${NC}"
    TOTAL=0
    SUCCESS=0
    FAILED=0
else
    # 計數器
    TOTAL=${#INDICES_ARRAY[@]}
    SUCCESS=0
    FAILED=0

    # 爬取每個指數的新聞
    for item in "${INDICES_ARRAY[@]}"; do
        IFS='|' read -r symbol name <<< "$item"

        echo -e "${YELLOW}正在爬取: $name ($symbol)${NC}"

        # 不再指定 -o 參數，讓爬蟲自動產生帶日期的檔名
        if python3 "$NEWS_SCRAPER" "$symbol" 2>/dev/null; then
            echo -e "${GREEN}✓ $name 完成${NC}"
            ((SUCCESS++))
        else
            echo -e "\033[0;31m✗ $name 失敗${NC}"
            ((FAILED++))
        fi
        echo ""
    done
fi

# 顯示統計資訊
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}總結${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}✓ 完成！${NC}"
echo ""
echo "【全球市場指數】"
if [ $INDICES_SUCCESS -eq 1 ]; then
    echo -e "  狀態: ${GREEN}成功${NC}"
else
    echo -e "  狀態: \033[0;31m失敗${NC}"
fi
echo ""
echo "【市場新聞】"
echo "  總共: $TOTAL 個市場"
echo -e "  成功: ${GREEN}$SUCCESS${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "  失敗: \033[0;31m$FAILED${NC}"
else
    echo -e "  失敗: $FAILED"
fi
echo ""
echo -e "${BLUE}========================================${NC}"
echo ""

# 列出生成的檔案
echo "【全球市場指數檔案】"
# 找今天的檔案
TODAY_DATE=$(date +%Y-%m-%d)
if ls -lh "$DAILY_DIR"/global-indices-*.md 2>/dev/null | tail -1; then
    ls -lh "$DAILY_DIR"/global-indices-*.md 2>/dev/null | tail -1 | awk '{print "  - " $9 " (" $5 ")"}'
fi
echo ""
echo "【市場新聞檔案】"
# 列出今天產生的新聞檔案
if ls -lh "$NEWS_DIR"/*-$TODAY_DATE.md 2>/dev/null; then
    ls -lh "$NEWS_DIR"/*-$TODAY_DATE.md 2>/dev/null | awk '{print "  - " $9 " (" $5 ")"}'
fi
echo ""
echo -e "指數資料路徑: ${GREEN}$DAILY_DIR${NC}"
echo -e "新聞資料路徑: ${GREEN}$NEWS_DIR${NC}"
echo -e "${BLUE}========================================${NC}"
