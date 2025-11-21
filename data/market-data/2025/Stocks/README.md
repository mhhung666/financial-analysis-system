# 個股歷史資料（時間序列）

本目錄存放個別股票的歷史價格資料（時間序列資料）。

## 📂 目錄說明

- **用途**：儲存單一股票的多日歷史資料
- **資料類型**：時間序列（縱向資料）
- **更新頻率**：定期更新（通常每日或每週）
- **資料來源**：Yahoo Finance (yfinance)

## 📊 資料格式

每個檔案包含一支股票的歷史 OHLCV 資料（開盤、最高、最低、收盤、成交量）：

```markdown
| Date         | Open   | High   | Low    | Close  | Adj Close | Volume     |
|--------------|--------|--------|--------|--------|-----------|------------|
| Nov 14, 2025 | 271.41 | 278.56 | 270.70 | 276.41 | 276.41    | 31,106,700 |
...
```

## 📁 檔案命名規則

- **格式**：`SYMBOL.md` 或 `SYMBOL-YYYY.md`
- **範例**：
  - `GOOGL.md` - Google 股價歷史資料
  - `ORCL.md` - Oracle 股價歷史資料
  - `UPS.md` - UPS 股價歷史資料

## 🔄 資料更新

使用以下指令更新個股資料：

```bash
# 啟動虛擬環境
source tools/python/venv/bin/activate

# 擷取個股歷史資料（範例：GOOGL）
python3 tools/python/scrapers/fetch_market_data.py GOOGL -o data/market-data/2025/Stocks/GOOGL.md

# 指定時間範圍
python3 tools/python/scrapers/fetch_market_data.py GOOGL --period 3mo -o data/market-data/2025/Stocks/GOOGL.md
```

## 📝 注意事項

1. **時間序列資料** - 每個檔案包含該股票的完整歷史資料
2. **定期更新** - 建議每週或每月更新一次，保持資料新鮮
3. **資料覆蓋** - 每次執行會覆蓋舊資料（建議定期備份）
4. **長期保存** - 適合用於技術分析、趨勢研究、回測等

## 🔗 相關目錄

- **[Daily/](../Daily/)** - 每日市場快照（單一日期，多個指數）
- **[News/](../News/)** - 個股相關新聞

---

*最後更新：2025-11-18*
