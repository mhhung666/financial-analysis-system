# 📋 財報分析知識庫 - TODO 清單

> 系統化追蹤待完成任務與未來擴充計畫 | 最後更新：2025-11-05

---

## 🎯 優先級說明

- 🔴 **高優先級** - 本週/本月完成，重要且緊急
- 🟡 **中優先級** - 本季完成，重要但不緊急
- 🟢 **低優先級** - 長期目標，未來逐步完成
- 💡 **想法池** - 未來可能的方向

---

## 🔴 高優先級（近期完成）

- [x] **修正索引連結與路徑**
  - `INDEX.md` 的「持股明細」連結改為 `analysis/2025Q3/...`，避免 404
  - 已檢查根層文件，其餘皆使用正確路徑
  - **完成日期：2025-11-18**

- [x] **統一 portfolio 入口**
  - 所有文件改為指向 `portfolio/2025/holdings.md`、`watchlist.md`、`performance.md`、`risk-matrix.md`
  - 更新 TODO/INDEX/GIT_GUIDE 連結與命令範例，確保點擊可直接進到 2025 資料
  - **完成日期：2025-11-18**

- [x] **更新工具與資料 README 範例**
  - `tools/python/README.md`, `tools/python/scrapers/README.md`, `data/market-data/2025/News/README.md` 等仍示範舊路徑（未含 `Stocks/` 與日期）
  - 加入 `SYMBOL-YYYY-MM-DD.md` 命名規範與 `Stocks/` 子目錄，確保文件與實際流程一致
  - **完成日期：2025-11-18**

- [x] **市場資料輸出加入日期時間戳**（功能已移轉至 `market-intelligence-system`，本專案保留歷史紀錄）

- [x] **統一季度分析資料夾結構**
  - `analysis/2025Q3` 現已統一為「資料夾 + README + Analysis.md」格式
  - 新增 `analysis/2025Q3/README.md` 彙整本季分析導覽
  - **完成日期：2025-11-18**

---

## 🟡 中優先級（本季完成）

- [x] **模組化爬蟲程式碼**
  - 在 `tools/python/scrapers/` 加入 `__init__.py` 與 `common.py`
  - 抽離 argparse / I/O / 錯誤處理，方便日後擴充

- [x] **外部化全球指數設定**
  - 將 `fetch_global_indices.py` 的硬編碼市場字典移到 `tools/python/config/indices.yaml`
  - 允許自訂追蹤市場並減少日後修改成本
  - **完成日期：2025-11-20**

- [ ] **集中化 ticker/company metadata**
  - 建立 `config/tickers.yaml`（或 `data/catalog/`）統一管理公司名稱、產業、交易所、模板版本
  - `new_analysis.py`、`fetch_holdings_prices.sh`、`INDEX.md` 引用此檔，避免多處重複維護
  - 之後新增公司或調整產業分類時，只需改單一來源，提高一致性

- [ ] **Python 工具套件化**
  - 將 `tools/python/` 重組為 `pyproject.toml + src/`，導出 `fra-*` CLI（如 `fra fetch-indices`、`fra new-analysis`）
  - 透過 entrypoints 取代 shell 包裝，減少 PATH/權限問題並方便單元測試
  - 有助於之後在 GitHub Actions/docker 中直接 `pip install -e tools/python`

---

## 🟢 低優先級（長期目標）

- [ ] **導入 logging 框架**
  - 以 `logging` 取代 `print(file=sys.stderr)`，並提供檔案輸出選項

- [x] **新增 pytest 測試**
  - 在 `tools/python/tests/` 為資料擷取、格式化、檔案輸出撰寫單元測試
  - **完成日期：2025-11-20**

- [ ] **資料與分析封存策略**
  - 2025 之後的季度/年度移動至 `archive/{year}/`，`analysis/market` 與 `data/market-data` 採年份月分子目錄，避免根目錄膨脹
  - 制定壓縮/刪除規則（例如保留每日快照 90 天、每月存一份長期檔），降低倉庫體積並加速 diff

- [ ] **輸出檔案 metadata 與驗證**
  - 為自動產生的 Markdown 加 front matter（ticker、來源、時區、產出腳本版本），並以簡單 schema 驗證
  - 產出後跑 `make validate-artifacts`（或 pytest plugin）確保格式一致、連結與日期欄位合規

---

## 💡 想法池

- [x] **INDEX 自動檢查腳本**
  - 建立 `tools/check-links.sh` 自動檢查 Markdown 連結是否存在
  - 使用 `make check-links` 即可執行
  - **完成日期：2025-11-20**

- [x] **季度報告產製自動化**
  - 腳本化從模板複製→建立資料夾→更新 INDEX 的流程，減少手動作業時間
  - 使用 `make new-analysis TICKER=AAPL NAME="Apple Inc."` 即可建立新分析
  - 或直接執行 `python tools/python/new_analysis.py TICKER "公司名稱"`
  - **完成日期：2025-11-20**

---

## 📊 進度追蹤

| 類別 | 已完成 | 進行中 | 待開始 | 完成率 |
|------|--------|--------|--------|--------|
| 🔴 高優先級 | 5 | 0 | 0 | 100% |
| 🟡 中優先級 | 2 | 0 | 2 | 50% |
| 🟢 低優先級 | 1 | 0 | 3 | 25% |
| 💡 想法池 | 2 | 0 | 0 | 100% |
| **總計** | **10** | **0** | **5** | **67%** |

## 💡 使用建議

### 如何使用這個 TODO？

1. **每週檢視**
   - 每週一花 10 分鐘檢視高優先級任務
   - 挑選 2-3 個本週要完成的任務
   - 標記進行中的項目

2. **每月回顧**
   - 月初檢視中優先級任務
   - 將完成的任務移到「已完成」區塊
   - 重新評估優先級

3. **靈活調整**
   - 根據市場情況調整優先級
   - 不要被清單綁架，保持彈性
   - 完成比完美更重要

4. **慶祝進度**
   - 每完成一個任務就打勾
   - 定期回顧已完成清單
   - 看到進步會更有動力

---

## 🔗 相關文件

- 📖 [README.md](README.md) - 系統使用指南
- 📑 [INDEX.md](INDEX.md) - 中央索引
- 💼 [持倉明細](portfolio/2025/holdings.md)
- 👀 [觀察清單](portfolio/2025/watchlist.md)

---

**建立日期**：2025-11-05
**最後更新**：2025-11-20（新增連結檢查腳本）
**下次檢視**：2025-11-25（每週一）

---

*記住：完成比完美更重要。每週完成 2-3 個任務，持續前進。投資是馬拉松，不是短跑。* 🚀
