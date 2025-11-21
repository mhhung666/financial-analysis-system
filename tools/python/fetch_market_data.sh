#!/bin/bash
#
# Wrapper script for tools/python/scrapers/fetch_market_data.py
# Provides a convenient entry point plus a descriptive --help message.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRAPER="$SCRIPT_DIR/scrapers/fetch_market_data.py"

show_help() {
    cat <<'EOF'
用法: ./fetch_market_data.sh [symbol] [選項]

此腳本會轉呼叫 tools/python/scrapers/fetch_market_data.py，讓 Makefile 或手動操作更方便。

參數（會原樣傳給 Python 腳本）:
  symbol           股票或匯率代碼（預設 JPY=X）
  -w, --weeks N    指定要抓取的週數（預設 52，若使用 -y 則忽略）
  -o, --output P   指定輸出檔案（僅檔名時自動存在 data/market-data/{YEAR}/Stocks/）
  -y, --year YYYY  只輸出指定年份的資料，會自動抓取整年度
  --stdout         只輸出到螢幕，不寫入檔案
  -h, --help       顯示 Python 腳本的幫助資訊

範例:
  # 直接抓取 UPS 並自動儲存到 data/market-data/{YEAR}/Stocks/UPS.md
  ./fetch_market_data.sh UPS

  # 抓取 Apple 過去 26 週的資料並指定輸出檔名
  ./fetch_market_data.sh AAPL -w 26 -o AAPL-26w.md

  # 抓取 UPS 的 2024 年資料並輸出到螢幕
  ./fetch_market_data.sh UPS -y 2024 --stdout
EOF
}

if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    echo ""
    python3 "$SCRAPER" --help
    exit 0
fi

python3 "$SCRAPER" "$@"
