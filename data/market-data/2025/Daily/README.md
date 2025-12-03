# 每日市場快照

本目錄存放每日更新的全球市場指數資料（單一日期的市場快照）。

## 📂 目錄說明

- **用途**：儲存特定日期的所有市場指數快照
- **資料類型**：橫向快照（單一時間點，多個標的）
- **更新頻率**：每日更新
- **資料來源**：Yahoo Finance (yfinance)

## 📊 資料說明

### global-indices.md

全球主要市場的大盤指數今日資料，包含：
- 18 個全球市場指數
- 8 個市場/地區（日本、韓國、台灣、中國、新加坡、香港、歐洲、美國）

**資料欄位：**
- 國家/地區
- 指數名稱
- 收盤價
- 開盤價
- 最高價
- 最低價
- 成交量
- 漲跌金額（🔺 上漲 / 🔻 下跌）
- 漲跌幅（百分比）

## 支援的市場指數

### 亞洲市場

| 地區 | 指數名稱 | 代碼 |
|------|---------|------|
| 日本 | 日經225 | `^N225` |
| 日本 | TOPIX | `^TPX` |
| 韓國 | KOSPI | `^KS11` |
| 韓國 | KOSDAQ | `^KQ11` |
| 台灣 | 台灣加權指數 | `^TWII` |
| 中國 | 上證指數 | `000001.SS` |
| 中國 | 深證成指 | `399001.SZ` |
| 中國 | 滬深300 | `000300.SS` |
| 新加坡 | 海峽時報指數 | `^STI` |
| 香港 | 恆生指數 | `^HSI` |
| 香港 | 國企指數 | `^HSCE` |

### 歐洲市場

| 地區 | 指數名稱 | 代碼 |
|------|---------|------|
| 歐洲 | STOXX 50 | `^STOXX50E` |
| 德國 | DAX | `^GDAXI` |
| 法國 | CAC 40 | `^FCHI` |
| 英國 | FTSE 100 | `^FTSE` |

### 美國市場

| 指數名稱 | 代碼 |
|---------|------|
| S&P 500 | `^GSPC` |
| Dow Jones | `^DJI` |
| NASDAQ | `^IXIC` |
| Russell 2000 | `^RUT` |

## 更新方式

### 快速更新

```bash
make fetch-indices      # 全球指數快照
make holdings-prices    # 持倉價格快照
```

### 手動更新

**更新所有市場指數：**
```bash
source tools/python/venv/bin/activate
python3 tools/python/scrapers/fetch_global_indices.py -o data/market-data/2025/Daily/global-indices.md
deactivate
```

**更新特定區域指數：**
```bash
source tools/python/venv/bin/activate

# 只更新亞洲市場
python3 tools/python/scrapers/fetch_global_indices.py -r 台灣 日本 韓國 中國 香港

# 只更新美國市場
python3 tools/python/scrapers/fetch_global_indices.py -r 美國

# 自訂區域組合
python3 tools/python/scrapers/fetch_global_indices.py -r 台灣 香港 美國

deactivate
```

## 資料格式

資料採用 Markdown 表格格式：

```markdown
# 全球市場大盤指數 - YYYY-MM-DD

**更新時間**: YYYY-MM-DD HH:MM:SS

| 國家/地區 | 指數名稱 | 收盤價 | 開盤 | 最高 | 最低 | 成交量 | 漲跌 | 漲跌幅 |
|----------|---------|--------|------|------|------|--------|------|--------|
| 日本 | 日經225 | 49,258.29 | 49,812.95 | 49,971.55 | 49,107.31 | — | 🔻 -554.66 | 🔻 -1.11% |
| ...
```

## 資料來源

- **API**: Yahoo Finance (`yfinance`)
- **資料類型**: 當日盤中/收盤資料
- **更新頻率**: 建議每日更新一次
- **免費使用**: 無需 API key

## 檔案說明

| 檔案 | 說明 | 更新方式 |
|------|------|---------|
| [global-indices.md](global-indices.md) | 全球市場指數 (18 個指數) | `make fetch-indices` 或手動執行 |

## 使用建議

### 每日例行更新
收盤後執行一次指數與持倉快照：

```bash
make fetch-indices
make holdings-prices
```

### 盤中查看
如需查看盤中即時資料，可手動執行：

```bash
source tools/python/venv/bin/activate
python3 tools/python/scrapers/fetch_global_indices.py
deactivate
```

## 📝 注意事項

- **資料覆蓋**：每次執行會覆蓋 `global-indices.md` 檔案
- **資料完整性**：部分指數可能因交易時間或資料來源問題無法取得（會顯示警告）
- **更新建議**：建議每日執行一次自動化腳本保持資料更新
- **時間基準**：資料時間以 UTC/當地市場時間為準

## 🔗 相關目錄

- **[Stocks/](../Stocks/)** - 個股歷史資料（時間序列，單一股票）
- **[News/](../News/)** - 市場新聞資料

## 📚 相關文件

- [爬蟲工具說明](../../../tools/python/scrapers/README.md)
- [Python 工具總覽](../../../tools/python/README.md)

---

*最後更新：2025-11-18*
