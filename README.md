# 📊 財報分析知識庫

> 整合財報閱讀、產業研究、投資組合追蹤與資料蒐集的個人研究系統

---

## 🎯 專案定位

- 建立可重複使用的股票/產業分析框架，所有分析都從 `templates/` 取得最新模板。
- 透過 `data/` 與 `analysis/` 的分工，讓原始資料與研究筆記保持乾淨、可追溯。
- `portfolio/` 與 `analysis/market/` 對接每日自動化腳本，確保投資決策與市場狀態同步。
- `INDEX.md`、`TODO.md` 與各季度 `README` 提供上下游對齊，避免遺漏。

---

## 🗂️ 知識庫地圖

```text
financial-report-analysis/
├── analysis/                # 核心分析工作區
│   ├── 2025Q2/, 2025Q3/     # 季度分析檔案（含個股子資料夾與 README）
│   ├── company-profiles/    # 公司檔案（*_profile.md）
│   ├── comparisons/         # 同業比較（例如 digital-ad-platforms.md）
│   └── market/              # 全球市場日誌（每日產出 1 檔）
├── data/                    # 原始數據
│   ├── earnings-transcripts/
│   ├── financial-statements/
│   └── market-data/
│       └── 2025/{Daily,News,Stocks}
├── portfolio/               # 投資組合與績效
│   ├── 2025/                # holdings/performance/risk/watchlist/options-performance
│   └── README.md            # 追蹤說明
├── research/                # 框架、概念與產業筆記
├── templates/               # 標準化模板（analysis/data/research/comparisons/portfolio）
├── tools/                   # 自動化腳本（python、notebooks）
├── Makefile                 # 快捷命令列入口
├── INDEX.md                 # 中央索引
├── TODO.md                  # 擴充與待辦
├── GIT_GUIDE.md             # Git 作業指引
└── README.md                # 本文件
```

---

## 📂 資料夾角色與交付物

### `analysis/`
- `YYYYQn/`：每季建立新資料夾，內含個股分析（依股票代碼命名）與季度 `README`。
- `company-profiles/`：基本資料檔案，維持與 `templates/data/company-profile.md` 同步。
- `comparisons/`：跨公司/產業比較，完成後在 `INDEX.md` 登錄。
- `market/`：**每日 AI 驅動的市場分析報告**，由 Claude 自動分析 `data/market-data/2025` 的指數、價格與新聞，生成專業的投資策略建議（使用 `make daily` 或 `make analyze-daily`）。

### `data/`
- `earnings-transcripts/` & `financial-statements/`：存放官方資料與拆解表，命名遵循 `YYYYQn`。
- `market-data/2025/`：
  - `Daily/`：全球指數快照（`global-indices-YYYY-MM-DD.md`）與持倉價格（`prices-YYYY-MM-DD.md`）。
  - `News/`：個股與指數的市場新聞（例如 `TSLA-YYYY-MM-DD.md`、`^GSPC-YYYY-MM-DD.md`）。
  - `Stocks/`：個股或匯率歷史資料，對應分析對象。

### `portfolio/`
- `2025/holdings.md`：實際資金部位與加減碼紀錄。
- `performance.md`、`options-performance.md`、`risk-matrix.md`：績效與風險儀表板。
- `watchlist.md`：觀察名單與觸發價。
- ~~`prices-YYYY-MM-DD.md`~~：已遷移至 `data/market-data/2025/Daily/prices-YYYY-MM-DD.md`，統一管理每日市場資料。

### `research/`
- `frameworks/`：分析流程、估值模型（例如 `dcf-methodology.md`）。
- `concepts/`：投資觀念與護城河研究。
- `industries/`：產業筆記，可搭配 `analysis/comparisons/`。

### `templates/`
- `analysis/`：`full-valuation.md`、`full-valuation-v2.md`、`standard-analysis.md`、`quick-review.md`、`industry-analysis.md`。
- `data/`：`company-profile.md`。
- `comparisons/`：`peer-comparison-template.md`。
- `research/`：`framework-template.md`、`concept-template.md`、`industry-note-template.md`。
- `portfolio/`：`holdings-template.md`、`performance-template.md`、`risk-matrix-template.md`、`watchlist-template.md`、`net-worth-tracking-template.md`。

### `tools/`
- `python/`：主要自動化腳本與虛擬環境（資料爬取、價格追蹤）。
- `notebooks/`：臨時探索或可視化。
- `analyze_daily_market.sh`：**Claude AI 市場分析引擎**，自動整合當日所有資料並生成深度分析報告。
- `ANALYZE_DAILY_README.md`：Claude AI 分析系統的完整使用文檔。
- 各腳本的輸出/依賴詳述於 `tools/README.md` 與 `tools/python/README.md`。

---

## 🔄 日常作業流程

### 1. 資料蒐集與每日快照

#### ⭐ **推薦：一鍵完成每日流程**
```bash
make daily
```
此命令會依序執行：
1. **資料爬取** - 全球指數、市場新聞
2. **持倉追蹤** - 所有持股的當日價格與新聞
3. **AI 分析** - Claude 自動生成專業市場分析報告（包含持倉建議、風險評估、投資策略）

輸出結果：
- `data/market-data/2025/Daily/global-indices-YYYY-MM-DD.md` - 全球市場概況
- `data/market-data/2025/Daily/prices-YYYY-MM-DD.md` - 持倉價格快照
- `data/market-data/2025/News/*-YYYY-MM-DD.md` - 個股與指數新聞
- `analysis/market/YYYY-MM-DD.md` - **AI 生成的完整市場分析報告**

#### 分步執行（可選）
1. **資料爬取**：`make fetch-daily` - 取得當日全球指數與市場新聞
2. **持倉追蹤**：`make holdings-prices-daily` - 更新持倉股票價格與新聞
3. **AI 分析**：`make analyze-daily` - 單獨運行 Claude 市場分析
4. **個股歷史**：`make fetch-market-data SYMBOL=UPS ARGS="..."` - 下載特定股票歷史資料

### 2. 建立或更新個股分析
1. 在 `analysis/YYYYQn/` 建立新目錄並從 `templates/analysis/` 複製適用模板。
2. 將原始資料整理進 `data/financial-statements/YYYYQn` 與 `data/earnings-transcripts/YYYYQn`。
3. 完成分析後同步更新：
   - `analysis/company-profiles/`（若為新公司）
   - `INDEX.md`（新增連結）
   - `portfolio/2025/holdings.md`、`performance.md`（如有部位變動）

### 3. 維護投資組合
- 使用 `templates/portfolio/` 確保 `holdings/performance/risk/watchlist/options-performance` 篇章一致。
- 定期銜接自動化輸出：
  - `prices-YYYY-MM-DD.md` → 轉換為 `performance.md` 月度摘要。
  - `analysis/market/` → 補充 `risk-matrix.md` 的宏觀敘述。

### 4. 研究與比較
- 產業研究從 `templates/research/industry-note-template.md` 開始，落地於 `research/industries/`。
- 同業比較放在 `analysis/comparisons/`，並與 `research/frameworks/` 交叉引用。
- 若完成系統性框架，於 `TODO.md` 標記後續應用場景。

---

## ⚙️ 自動化與工具

### Makefile 指令

#### 🚀 每日必備
- **`make daily`**：⭐ **一鍵完成每日流程** - 依序執行資料爬取、持倉追蹤、AI 分析，輸出完整市場報告
- `make analyze-daily`：單獨運行 Claude AI 市場分析（需先有當日資料）

#### 📊 資料收集
- `make setup`：執行 `tools/python/setup.sh`，建立虛擬環境並安裝依賴
- `make fetch-daily`：爬取當日全球指數與市場新聞
- `make holdings-prices-daily`：更新持倉股票價格與新聞（包含 `--news` 參數）
- `make fetch-market-data SYMBOL=UPS ARGS="-w 52"`：下載單一股票歷史資料

#### 🛠️ 輔助工具
- `make check-links`：檢查 Markdown 連結有效性
- `make new-analysis TICKER=AAPL NAME="Apple Inc."`：建立新的季度分析資料夾

### `tools/` 腳本與工具

#### Python 資料爬取腳本
- `python/fetch_daily_market_news.sh`：整合全球指數與市場新聞爬取
- `python/fetch_holdings_prices.sh`：讀取持倉配置，輸出價格與新聞報表
- `python/scrapers/fetch_market_data.py`：下載股票/匯率歷史資料
- `python/scrapers/fetch_global_indices.py`：支援 18 個全球市場指數
- `python/scrapers/fetch_market_news.py`：爬取 Yahoo Finance 新聞（Markdown/JSON 格式）

#### 🤖 AI 分析系統
- **`analyze_daily_market.sh`**：Claude AI 市場分析引擎
  - 自動整合當日所有資料（指數、價格、新聞）
  - 生成專業的投資分析報告（15-20 頁 Markdown）
  - 包含：持倉股票深度分析、風險評估、投資策略建議、後市展望
  - 詳細文檔：[tools/ANALYZE_DAILY_README.md](tools/ANALYZE_DAILY_README.md)

#### 其他工具
- `notebooks/`：Jupyter notebook 臨時分析與可視化

---

## 🧱 模板與命名規範

- **個股分析**：`[TICKER]_[YYYY]Q[Q]_[type].md`，範例 `UPS_2025Q3_standard-analysis.md`。
- **公司檔案**：`[TICKER]_profile.md`，儲存於 `analysis/company-profiles/`。
- **比較報告**：`[theme]-comparison.md`，放在 `analysis/comparisons/`。
- **市場日誌**：`analysis/market/YYYY-MM-DD.md`，對應 `data/market-data/2025/Daily` 與 `News`。
- **每日價格快照**：`portfolio/2025/prices-YYYY-MM-DD.md`，由腳本自動命名。
- 建議所有新檔案都從 `templates/` 複製，避免格式漂移；若模板改版，請同步在 `README` 或 `TODO` 註記。

---

## 📆 維護節奏

- **每日**：⭐ 執行 **`make daily`**（或分步執行 `fetch-daily` + `holdings-prices-daily` + `analyze-daily`）
  - 自動更新全球市場資料、持倉價格、個股新聞
  - 生成 AI 驅動的市場分析報告到 `analysis/market/YYYY-MM-DD.md`
  - 根據 AI 建議調整 `portfolio/2025/watchlist.md` 與持倉策略

- **每週**：
  - 回顧 `analysis/market/` 本週所有報告，提取關鍵投資主題
  - 審視 `watchlist.md` 觸發價位
  - 補充 `research/industries/` 或 `concepts/` 的新發現

- **每月**：
  - 彙整 `portfolio/2025/performance.md`、`options-performance.md`
  - 檢查 `risk-matrix.md` 是否反映最新市場情境
  - 根據 Claude AI 月度建議調整投資組合配置

- **每季**：
  - 建立新的 `analysis/YYYYQn/` 資料夾
  - 完成重要持倉的 `full-valuation` 或 `standard-analysis`
  - 將上季資料彙整入 `INDEX.md`

- **年度**：
  - 整理 `TODO.md` 與 `INDEX.md`
  - 規劃新年度研究主題
  - 必要時建立 `archive/` 封存舊資料

---

## 📎 快速參考

### 核心文檔
- [INDEX.md](INDEX.md)：中央目錄，列出所有分析、資料與連結
- [TODO.md](TODO.md)：下一步擴充與技術債清單
- [Makefile](Makefile)：所有可用命令的入口

### 分析與資料
- [analysis/2025Q3/README.md](analysis/2025Q3/README.md)：當季交付物與進度
- [analysis/market/](analysis/market/)：每日 AI 市場分析報告
- [portfolio/2025/](portfolio/2025/)：實際部位、績效與風險控管

### 模板與工具
- [templates/README.md](templates/README.md)：模板索引與使用指南
- [tools/python/README.md](tools/python/README.md)：Python 自動化工具詳細說明
- [tools/ANALYZE_DAILY_README.md](tools/ANALYZE_DAILY_README.md)：⭐ **Claude AI 市場分析系統完整文檔**

### 🆕 重要更新
- **2025-11-21**：新增 Claude AI 自動化市場分析系統
  - 一鍵命令 `make daily` 整合資料爬取與 AI 分析
  - 每日生成 15-20 頁專業市場分析報告
  - 包含持倉建議、風險評估、投資策略
  - 詳見 [tools/ANALYZE_DAILY_README.md](tools/ANALYZE_DAILY_README.md)

---

## ⚠️ 免責聲明

本知識庫僅供個人研究與紀錄，不構成投資建議。金融市場具高度風險，請依自身風險承受度獨立決策並自行負責。
