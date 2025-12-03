# Tools Directory

自動化腳本與分析工具集。每日新聞爬蟲與 AI 報告工作流已搬到 `../market-intelligence-system`，此處只保留資料抓取與維護腳本。

## 快速開始

### 一鍵安裝環境
```bash
bash tools/python/setup.sh
```

### 取得每日快照
```bash
make fetch-indices      # 全球市場指數快照
make holdings-prices    # 持倉價格快照（儲存到 data/market-data/{YEAR}/Daily/）
```

## 目錄結構

```
tools/
├── python/                           # Python 工具集
│   ├── fetch_holdings_prices.sh      # 持倉股票價格追蹤腳本
│   ├── fetch_market_data.sh          # 單一股票/匯率歷史資料包裝腳本
│   ├── scrapers/                     # 爬蟲工具
│   │   ├── fetch_market_data.py      # 股票/匯率歷史資料爬蟲
│   │   ├── fetch_global_indices.py   # 全球市場指數爬蟲
│   │   ├── fetch_holdings_prices.py  # 持倉股票價格獲取工具
│   │   └── README.md                 # 爬蟲工具詳細說明
│   ├── setup.sh                      # 環境安裝腳本
│   ├── requirements.txt              # Python 依賴套件
│   └── README.md                     # Python 工具說明
├── utils/                            # 通用工具腳本
│   ├── README.md                     # 工具說明
│   └── check-links.sh                # Markdown 連結檢查工具
└── notebooks/                        # Jupyter Notebooks
    └── README.md
```

## 主要工具

### 1. 全球市場指數 (`scrapers/fetch_global_indices.py`)
```bash
python3 tools/python/scrapers/fetch_global_indices.py
```
- 18 個全球市場指數、8 個市場/地區
- 可使用 `-r` 指定區域、`-o` 指定輸出檔案

### 2. 持倉股票價格 (`fetch_holdings_prices.sh`)
```bash
./tools/python/fetch_holdings_prices.sh        # 預設儲存到 data/market-data/{YEAR}/Daily/
./tools/python/fetch_holdings_prices.sh --no-save  # 只輸出到螢幕
```
- 自動從 `portfolio/{YEAR}/holdings.md` 提取代碼
- 顯示即時價格、漲跌幅與市場概況

### 3. 個別爬蟲工具
- 歷史資料：`python3 tools/python/scrapers/fetch_market_data.py AAPL -w 52 -o data/market-data/2025/Stocks/AAPL.md`
- 指數快照：`python3 tools/python/scrapers/fetch_global_indices.py -r 台灣 美國`
- 持倉價格：`python3 tools/python/scrapers/fetch_holdings_prices.py -o portfolio/2025/prices-YYYY-MM-DD.md`

### 4. 連結檢查 (`utils/check-links.sh`)
```bash
make check-links
```
- 檢查所有 Markdown 內部連結是否有效

## 使用場景

- **每日資料更新**：`make fetch-indices` → `make holdings-prices`
- **抓取特定標的歷史資料**：`python3 tools/python/scrapers/fetch_market_data.py TSLA -w 52 -o data/market-data/2025/Stocks/TSLA.md`
- **驗證文件連結**：`make check-links`
- **需要新聞或 AI 報告**：請在 `../market-intelligence-system` 執行對應工作流
