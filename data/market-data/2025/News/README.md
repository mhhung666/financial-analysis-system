# 市場新聞資料

本目錄存放從 Yahoo Finance 爬取的金融新聞。

## 資料說明

每個檔案包含特定股票或市場指數的最新新聞（預設 10 則），包括：
- 新聞標題
- 摘要內容
- 新聞來源（Yahoo Finance、WSJ、Barrons、Investor's Business Daily 等）
- 發布時間
- 新聞連結
- 新聞類型（文章 📰 或影片 🎥）

## 檔案命名規範

- 統一使用：`data/market-data/{YEAR}/News/{SYMBOL}-{YYYY-MM-DD}.md`
- `SYMBOL` 可為股票代碼或指數識別（如 `SP500`, `NASDAQ`）
- 日期建議採用報導對應的交易日，確保長期可追蹤

## 主要市場指數新聞

每日自動更新的 4 個主要市場指數新聞（命名格式 `指數-YYYY-MM-DD.md`）：

| 檔案範例 | 市場指數 | 代碼 | 說明 |
|----------|---------|------|------|
| `SP500-2025-11-18.md` | S&P 500 | `^GSPC` | 美國標普 500 指數 |
| `NASDAQ-2025-11-18.md` | NASDAQ | `^IXIC` | 美國那斯達克綜合指數 |
| `HangSeng-2025-11-18.md` | 恆生指數 | `^HSI` | 香港恆生指數 |
| `DowJones-2025-11-18.md` | 道瓊工業指數 | `^DJI` | 美國道瓊工業平均指數 |

## 個股新聞

依需求手動爬取的個股新聞，統一命名為 `股票代碼-YYYY-MM-DD.md`，例如：
- `AAPL-2025-11-18.md` - Apple
- `TSLA-2025-11-18.md` - Tesla
- `NVDA-2025-11-18.md` - Nvidia
- `GOOGL-2025-11-18.md` - Google
- `MSFT-2025-11-18.md` - Microsoft

## 更新方式

### 自動更新（推薦）

使用每日自動化腳本更新主要市場新聞：

```bash
./tools/python/fetch_daily_market_news.sh
```

此腳本會自動更新 4 個主要市場指數的新聞，並各自建立 `*-YYYY-MM-DD.md` 檔案。

### 手動更新

**更新特定市場指數新聞：**
```bash
# 啟動虛擬環境
source tools/python/venv/bin/activate

# S&P 500
python3 tools/python/scrapers/fetch_market_news.py "^GSPC" -o data/market-data/2025/News/SP500-2025-11-18.md

# NASDAQ
python3 tools/python/scrapers/fetch_market_news.py "^IXIC" -o data/market-data/2025/News/NASDAQ-2025-11-18.md

# 恆生指數
python3 tools/python/scrapers/fetch_market_news.py "^HSI" -o data/market-data/2025/News/HangSeng-2025-11-18.md

# 道瓊工業指數
python3 tools/python/scrapers/fetch_market_news.py "^DJI" -o data/market-data/2025/News/DowJones-2025-11-18.md

deactivate
```

**爬取個股新聞：**
```bash
source tools/python/venv/bin/activate

# Apple
python3 tools/python/scrapers/fetch_market_news.py AAPL -o data/market-data/2025/News/AAPL-2025-11-18.md

# Tesla
python3 tools/python/scrapers/fetch_market_news.py TSLA -o data/market-data/2025/News/TSLA-2025-11-18.md

# Nvidia
python3 tools/python/scrapers/fetch_market_news.py NVDA -o data/market-data/2025/News/NVDA-2025-11-18.md

deactivate
```

## 資料格式

每個新聞檔案採用 Markdown 格式，結構如下：

```markdown
# [股票代碼] 最新金融新聞

**更新時間**: YYYY-MM-DD HH:MM:SS
**新聞數量**: N 則

---

## 1. [類型] 新聞標題

**來源**: 新聞來源
**發布時間**: 發布日期時間
**連結**: [URL](URL)

**摘要**:
新聞摘要內容...

---
```

## 資料來源

- **API**: Yahoo Finance (`yfinance`)
- **新聞來源**: Yahoo Finance、WSJ、Barrons、Investor's Business Daily 等
- **免費使用**: 無需 API key

## 注意事項

- 新聞內容會隨時更新，建議定期執行爬蟲保持資料新鮮度
- 建議檔名包含日期（`SYMBOL-YYYY-MM-DD.md`），可保留每日快照
- 建議每日執行一次自動化腳本
- 新聞數量預設為 10 則，可透過 `-l` 參數調整

## 相關文件

- [爬蟲工具說明](../../../tools/python/scrapers/README.md)
- [Python 工具總覽](../../../tools/python/README.md)
- [每日自動化腳本](../../../tools/python/fetch_daily_market_news.sh)
