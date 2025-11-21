# Python 工具

Python 自動化工具集，包含市場資料爬蟲和每日自動更新腳本。

## 快速開始

### 步驟 1: 安裝環境

**一鍵安裝**（推薦）
```bash
bash tools/python/setup.sh
```

**或手動安裝**
```bash
python3 -m venv tools/python/venv
source tools/python/venv/bin/activate
pip install -r tools/python/requirements.txt
```

### 步驟 2: 使用工具

**方式 1: 一鍵執行每日更新** ⭐ 推薦
```bash
./tools/python/fetch_daily_market_news.sh
```

自動爬取：
- 18 個全球市場指數
- 4 個主要市場新聞（S&P 500、NASDAQ、恆生、道瓊）

**方式 2: 使用個別爬蟲**
```bash
# 啟動虛擬環境
source tools/python/venv/bin/activate

# 使用爬蟲工具
python3 tools/python/scrapers/fetch_market_data.py AAPL -o data/market-data/2025/Stocks/AAPL.md

# 用完後停用
deactivate
```

## 工具列表

### 1. 每日市場資料腳本 (`fetch_daily_market_news.sh`) ⭐

**一鍵執行**，自動爬取全球市場指數和新聞。

```bash
./tools/python/fetch_daily_market_news.sh
```

**執行流程：**
1. 爬取全球市場指數 → `data/market-data/2025/Daily/global-indices-YYYY-MM-DD.md`
2. 爬取市場新聞 → `data/market-data/2025/News/*-YYYY-MM-DD.md`

**輸出檔案：**
- `Daily/global-indices-YYYY-MM-DD.md` - 18 個全球市場指數（日本、韓國、台灣、中國、香港、歐美等）
- `News/SP500-YYYY-MM-DD.md` - S&P 500 新聞
- `News/NASDAQ-YYYY-MM-DD.md` - NASDAQ 新聞
- `News/HangSeng-YYYY-MM-DD.md` - 恆生指數新聞
- `News/DowJones-YYYY-MM-DD.md` - 道瓊指數新聞

### 📁 輸出檔案命名規範

- 歷史價格資料：`data/market-data/{YEAR}/Stocks/{SYMBOL}.md`（手動一次抓整年度資料，不覆蓋日期）
- 每日市場指數：`data/market-data/{YEAR}/Daily/global-indices-{YYYY-MM-DD}.md`
- 市場新聞：`data/market-data/{YEAR}/News/{SYMBOL}-{YYYY-MM-DD}.md`
- 建議使用交易日作為日期，確保每次執行都建立一份完整快照。

### 2. 個別爬蟲工具

詳細說明請見 [scrapers/README.md](scrapers/README.md)

#### 股票/匯率歷史資料 (`scrapers/fetch_market_data.py`)

爬取股票或匯率歷史價格資料。

```bash
# 爬取 USD/JPY 匯率 (52週)
python3 tools/python/scrapers/fetch_market_data.py JPY=X -o data/market-data/2025/Stocks/USDJPY.md

# 爬取 Apple 股票 (26週)
python3 tools/python/scrapers/fetch_market_data.py AAPL -w 26 -o data/market-data/2025/Stocks/AAPL.md
```

**常用代碼:**
- 股票: `AAPL` `TSLA` `MSFT` `UPS` `GOOGL`
- 匯率: `JPY=X` `EUR=X` `GBP=X`

#### 全球市場指數 (`scrapers/fetch_global_indices.py`)

爬取全球主要市場的大盤指數今日資料。

```bash
# 爬取所有市場指數
python3 tools/python/scrapers/fetch_global_indices.py

# 爬取特定區域
python3 tools/python/scrapers/fetch_global_indices.py -r 台灣 美國 日本
```

**支援市場:** 日本、韓國、台灣、中國、新加坡、香港、歐洲、美國（共 18 個指數）

> 💡 市場設定存於 `config/indices.yaml`，可自訂追蹤市場。

#### 金融新聞 (`scrapers/fetch_market_news.py`)

爬取特定股票或指數的最新金融新聞。

```bash
# 爬取 Apple 新聞
python3 tools/python/scrapers/fetch_market_news.py AAPL -o data/market-data/2025/News/AAPL-2025-11-18.md

# 爬取 S&P 500 新聞
python3 tools/python/scrapers/fetch_market_news.py "^GSPC" -o data/market-data/2025/News/SP500-2025-11-18.md

# 輸出 JSON 格式
python3 tools/python/scrapers/fetch_market_news.py NVDA --json -o news.json
```

**支援代碼:**
- 股票: `AAPL` `TSLA` `NVDA` `MSFT` `GOOGL` 等
- 指數: `^GSPC` (S&P 500), `^DJI` (道瓊), `^IXIC` (NASDAQ), `^HSI` (恆生) 等

## 目錄結構

```
tools/python/
├── fetch_daily_market_news.sh      # 每日市場資料與新聞自動爬取腳本
├── config/                          # 配置檔案目錄
│   └── indices.yaml                # 全球市場指數設定
├── scrapers/                        # 爬蟲工具目錄
│   ├── __init__.py                 # 模組初始化
│   ├── common.py                   # 共用功能模組
│   ├── fetch_market_data.py        # 股票/匯率歷史資料爬蟲
│   ├── fetch_global_indices.py     # 全球市場指數爬蟲
│   ├── fetch_market_news.py        # 金融新聞爬蟲
│   ├── fetch_holdings_prices.py    # 持倉股票價格爬蟲
│   └── README.md                   # 爬蟲工具詳細說明
├── tests/                           # 單元測試
│   ├── conftest.py                 # pytest 配置
│   └── test_common.py              # common.py 測試
├── setup.sh                        # 環境安裝腳本
├── requirements.txt                # Python 依賴套件
└── venv/                           # Python 虛擬環境（不納入 Git）
```

## 依賴套件

所有工具使用的 Python 套件（定義於 `requirements.txt`）：

- `yfinance` - Yahoo Finance API，用於爬取市場資料和新聞
- `pandas` - 資料處理和分析
- `pyyaml` - YAML 配置檔案解析
- `pytest` - 單元測試框架

## 執行測試

```bash
# 啟動虛擬環境
source tools/python/venv/bin/activate

# 執行所有測試
pytest tools/python/tests/ -v

# 執行特定測試檔案
pytest tools/python/tests/test_common.py -v

# 顯示測試覆蓋率（需安裝 pytest-cov）
pytest tools/python/tests/ --cov=tools/python/scrapers --cov-report=term-missing

deactivate
```

## 使用場景

### 每日例行更新
```bash
# 建議每日執行一次
./tools/python/fetch_daily_market_news.sh
```

### 爬取特定股票完整資料
```bash
source tools/python/venv/bin/activate

# 歷史價格
python3 tools/python/scrapers/fetch_market_data.py TSLA -w 52 -o data/market-data/2025/Stocks/TSLA.md

# 最新新聞
python3 tools/python/scrapers/fetch_market_news.py TSLA -o data/market-data/2025/News/TSLA-2025-11-18.md

deactivate
```

### 自訂市場研究
```bash
source tools/python/venv/bin/activate

# 爬取特定市場指數
python3 tools/python/scrapers/fetch_global_indices.py -r 台灣 香港 日本

# 爬取多家公司新聞
python3 tools/python/scrapers/fetch_market_news.py AAPL -o data/market-data/2025/News/AAPL-2025-11-18.md
python3 tools/python/scrapers/fetch_market_news.py MSFT -o data/market-data/2025/News/MSFT-2025-11-18.md

deactivate
```

## 注意事項

- Python 虛擬環境位於 `venv/` 目錄，已加入 `.gitignore`，不會被 Git 追蹤
- 所有爬蟲使用 Yahoo Finance API，免費且無需 API key
- 每次使用個別爬蟲前記得啟動虛擬環境
- 建議每日執行 `fetch_daily_market_news.sh` 保持資料更新
