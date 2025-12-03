# Python 工具

Python 自動化工具集，負責市場資料抓取與日常維護。新聞爬蟲與 AI 報告工作流已搬到 `../market-intelligence-system`。

## 快速開始

### 步驟 1: 安裝環境
```bash
bash tools/python/setup.sh
```

### 步驟 2: 取得市場快照
```bash
# 全球市場指數
python3 tools/python/scrapers/fetch_global_indices.py

# 持倉股票價格（自動儲存到 data/market-data/{YEAR}/Daily/）
./tools/python/fetch_holdings_prices.sh
```

## 工具列表

### 1. 全球市場指數 (`scrapers/fetch_global_indices.py`)
- 爬取 18 個全球市場指數（亞洲、歐洲、美國）
- 參數：`-r/--regions` 指定區域、`-o/--output` 指定檔案、`--no-emoji` 關閉 emoji

### 2. 持倉股票價格 (`fetch_holdings_prices.sh` / `scrapers/fetch_holdings_prices.py`)
- 自動從 `portfolio/{YEAR}/holdings.md` 讀取股票代碼
- 支援 `--no-save` 只輸出到螢幕、`-v/--verbose` 顯示詳細資訊
- 預設輸出：`data/market-data/{YEAR}/Daily/prices-YYYY-MM-DD.md`

### 3. 歷史資料爬蟲 (`scrapers/fetch_market_data.py`)
- 爬取單一股票或匯率的歷史價格資料
- 參數：`-w/--weeks` 週數、`-o/--output` 指定檔案、`-y/--year` 抓取指定年度
- 範例：`python3 tools/python/scrapers/fetch_market_data.py AAPL -w 52 -o data/market-data/2025/Stocks/AAPL.md`

### 4. YAML 轉 Markdown (`yaml_to_markdown.py`)
- 將既有的 YAML 報告轉為 Markdown：`python3 tools/python/yaml_to_markdown.py analysis/market/2025-12-01.yaml analysis/market/2025-12-01.md`

> 需要新聞摘要或 AI 分析請改用 `market-intelligence-system`。

## 目錄構成

```
tools/python/
├── fetch_holdings_prices.sh      # 持倉價格包裝腳本
├── fetch_market_data.sh          # 歷史資料包裝腳本
├── scrapers/                     # 爬蟲工具
│   ├── fetch_market_data.py      # 股票/匯率歷史資料
│   ├── fetch_global_indices.py   # 全球指數快照
│   ├── fetch_holdings_prices.py  # 持倉價格
│   └── README.md                 # 詳細說明
├── yaml_to_markdown.py           # YAML 轉 Markdown
├── config/                       # 指數設定等
├── setup.sh                      # 環境安裝
├── requirements.txt              # 依賴套件
└── tests/                        # 測試
```

## 注意事項

- Python 虛擬環境位於 `tools/python/venv/`，已加入 `.gitignore`
- 所有爬蟲使用 Yahoo Finance API，免費且無需 API key
- 執行爬蟲前可先 `source tools/python/venv/bin/activate`

## 常用操作

```bash
# 每日更新全球指數與持倉價格
make fetch-indices
make holdings-prices

# 抓取特定標的歷史資料
python3 tools/python/scrapers/fetch_market_data.py TSLA -w 26 -o data/market-data/2025/Stocks/TSLA.md

# 驗證連結（在專案根目錄）
make check-links
```
