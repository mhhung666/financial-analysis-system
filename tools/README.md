# Tools Directory

自動化腳本與分析工具集。

## 快速開始

### 一鍵安裝環境
```bash
bash tools/python/setup.sh
```

### 一鍵爬取每日市場資料與新聞
```bash
# 同時爬取全球市場指數 + 主要市場新聞
./tools/python/fetch_daily_market_news.sh
```

這將自動產生：
- 全球市場指數：`data/market-data/YYYY/Daily/global-indices-YYYY-MM-DD.md`
- 市場新聞：`data/market-data/YYYY/News/SYMBOL-YYYY-MM-DD.md` (S&P 500、NASDAQ、恆生、道瓊)

## 目錄結構

```
tools/
├── python/                              # Python 工具集
│   ├── fetch_daily_market_news.sh      # 每日市場資料與新聞自動爬取腳本
│   ├── fetch_holdings_prices.sh        # 持倉股票價格追蹤腳本
│   ├── scrapers/                        # 爬蟲工具
│   │   ├── fetch_market_data.py        # 股票/匯率歷史資料爬蟲
│   │   ├── fetch_global_indices.py     # 全球市場指數爬蟲
│   │   ├── fetch_market_news.py        # 金融新聞爬蟲
│   │   ├── fetch_holdings_prices.py    # 持倉股票價格獲取工具
│   │   └── README.md                   # 爬蟲工具詳細說明
│   ├── setup.sh                        # 環境安裝腳本
│   ├── requirements.txt                # Python 依賴套件
│   └── README.md                       # Python 工具說明
└── notebooks/                          # Jupyter Notebooks
    └── README.md
```

## 主要工具

### 1. 每日市場資料腳本 (`fetch_daily_market_news.sh`) ⭐ 推薦

**一鍵執行**，自動爬取全球市場指數和主要市場新聞。

```bash
./tools/python/fetch_daily_market_news.sh
```

**功能：**
- 爬取 18 個全球市場指數（日本、韓國、台灣、中國、新加坡、香港、歐洲、美國）
- 爬取 4 個主要市場新聞（S&P 500、NASDAQ、恆生、道瓊）

**輸出：**
- `data/market-data/YYYY/Daily/global-indices-YYYY-MM-DD.md` - 全球市場指數
- `data/market-data/YYYY/News/^GSPC-YYYY-MM-DD.md` - S&P 500 新聞
- `data/market-data/YYYY/News/^IXIC-YYYY-MM-DD.md` - NASDAQ 新聞
- `data/market-data/YYYY/News/^HSI-YYYY-MM-DD.md` - 恆生指數新聞
- `data/market-data/YYYY/News/^DJI-YYYY-MM-DD.md` - 道瓊指數新聞

### 2. 持倉股票價格追蹤 (`fetch_holdings_prices.sh`) ⭐ 推薦

**一鍵執行**，自動從 [portfolio/2025/holdings.md](../portfolio/2025/holdings.md) 提取股票代碼並獲取當天價格資訊。

```bash
./tools/python/fetch_holdings_prices.sh
```

或使用快捷腳本：
```bash
./check-holdings.sh
```

或使用 Makefile：
```bash
make holdings-prices
```

**功能：**
- ✅ 自動從 `portfolio/2025/holdings.md` 提取股票代碼
- ✅ 獲取每隻股票的即時價格資訊
- ✅ 顯示漲跌幅（🟢 上漲 / 🔴 下跌 / ⚪ 持平）
- ✅ 計算市場概況統計
- ✅ 自動儲存為帶日期的 Markdown 文件

**輸出：**
- `portfolio/2025/prices-YYYY-MM-DD.md` - 自動儲存當天價格快照（預設行為）

**顯示資訊：**
對於每隻股票，工具會顯示：
- 代碼、名稱、當前價格
- 漲跌、漲跌幅
- 開盤價、最高價、最低價
- 成交量、市值

**進階用法：**

```bash
# 僅顯示到螢幕，不儲存檔案
./tools/python/fetch_holdings_prices.sh --no-save

# 顯示詳細資訊
./tools/python/fetch_holdings_prices.sh --verbose

# 指定不同的 holdings 檔案
python3 tools/python/scrapers/fetch_holdings_prices.py -i portfolio/2024/holdings.md

# 查看幫助資訊
./tools/python/fetch_holdings_prices.sh --help
```

**輸出範例：**

```markdown
# 📊 持倉股票價格分析

> 更新時間: 2025-11-18

---

| 代碼 | 名稱 | 當前價格 | 漲跌 | 漲跌幅 | 開盤 | 最高 | 最低 | 成交量 | 市值 |
|------|------|----------|------|--------|------|------|------|--------|------|
| U | Unity Software Inc. | $36.67 | -$0.05 | 🔴 -0.14% | $36.60 | $37.63 | $36.10 | 6,872,500 | $15.69B |
| GOOGL | Alphabet Inc. | $285.02 | +$8.61 | 🟢 +3.11% | $285.78 | $293.95 | $283.57 | 52,577,600 | $3452.20B |
...

---

## 📈 市場概況

- **總股票數**: 15
- **上漲**: 🟢 3 (20.0%)
- **下跌**: 🔴 12 (80.0%)
- **持平**: ⚪ 0 (0.0%)
```

**注意事項：**
- 工具獲取的是最新可用數據，盤中價格可能有延遲
- 需要穩定的網路連線訪問 Yahoo Finance
- 確保 holdings.md 中的股票代碼正確（美股使用標準代碼，其他市場可能需要後綴，如 `.SI` 代表新加坡）

### 3. 個別爬蟲工具

詳見 [python/scrapers/README.md](python/scrapers/README.md)

- **股票/匯率歷史資料** - `fetch_market_data.py`
- **全球市場指數** - `fetch_global_indices.py`
- **金融新聞** - `fetch_market_news.py`
- **持倉股票價格** - `fetch_holdings_prices.py`

### 4. Jupyter Notebooks

詳見 [notebooks/README.md](notebooks/README.md)

## 使用說明

### 環境管理

```bash
# 啟動 Python 虛擬環境
source tools/python/venv/bin/activate

# 使用完畢後停用
deactivate
```

### 常見使用場景

**場景 1：每日例行更新**
```bash
# 一鍵更新所有市場資料
./tools/python/fetch_daily_market_news.sh

# 查看持倉股票當天價格
./tools/python/check-holdings.sh
```

**場景 2：完整每日分析流程**
```bash
# 先獲取大盤資訊
make fetch-daily

# 再查看持倉表現
make holdings-prices
```

**場景 3：爬取特定股票歷史資料**
```bash
source tools/python/venv/bin/activate
python3 tools/python/scrapers/fetch_market_data.py AAPL -w 52 -o data/market-data/2025/Stocks/AAPL.md
```

**場景 4：爬取特定股票新聞**
```bash
source tools/python/venv/bin/activate
# 自動產生帶日期的檔名（預設行為）
python3 tools/python/scrapers/fetch_market_news.py TSLA
# 輸出: data/market-data/2025/News/TSLA-2025-11-18.md
```

## 注意事項

- Python 虛擬環境位於 `tools/python/venv/`，已加入 `.gitignore`
- 所有爬蟲使用 Yahoo Finance API，免費且無需 API key
- 建議每日執行 `fetch_daily_market_news.sh` 保持資料更新
