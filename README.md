# 📊 財報分析知識庫

> 整合財報閱讀、產業研究、投資組合追蹤與資料蒐集的個人研究系統

---

## 🎯 專案簡介

這是一個系統化的投資研究工作流，透過標準化模板與自動化工具，協助你：

- 📈 **每日市場資料紀錄** - 爬取全球市場指數與持倉價格快照（新聞爬蟲與 AI 分析已移至 `market-intelligence-system`）
- 📑 **季度財報分析** - 使用結構化模板進行深度研究
- 💼 **投資組合管理** - 追蹤持倉、績效與風險
- 🔍 **產業研究** - 建立可重複使用的分析框架

---

## 🚀 快速開始

### 1️⃣ 環境設置

```bash
# 安裝 Python 依賴
make setup
```

### 2️⃣ 取得市場快照

```bash
# 全球市場指數快照
make fetch-indices

# 更新持倉價格快照
make holdings-prices
```

輸出結果：
- `data/market-data/2025/Daily/` - 全球指數與持倉價格快照

> 新聞爬蟲與 AI 生成的市場日報已搬到 `../market-intelligence-system`。此專案保留資料抓取腳本與研究模板。

### 3️⃣ 開始分析股票

```bash
# 建立新的季度分析
make new-analysis TICKER=AAPL NAME="Apple Inc." QUARTER=2025Q4

# 從 templates/ 複製適合的分析模板開始撰寫
```

---

## 📁 專案結構

```
financial-analysis-system/
├── analysis/           # 分析報告與研究
│   ├── 2025Q3/         # 季度財報分析
│   ├── market/         # 每日市場分析（AI 生成）
│   └── comparisons/    # 同業比較
│
├── data/               # 原始數據
│   ├── market-data/    # 市場資料（自動爬取）
│   ├── financial-statements/  # 財務報表
│   └── earnings-transcripts/  # 法說會逐字稿
│
├── portfolio/          # 投資組合
│   └── 2025/           # 持倉、績效、風險
│
├── research/           # 研究框架與筆記
│   ├── frameworks/     # 分析方法論
│   ├── concepts/       # 投資概念
│   └── industries/     # 產業研究
│
├── templates/          # 標準化模板
│   ├── analysis/       # 市場分析模板（含 YAML 模板系統）
│   ├── portfolio/      # 投資組合模板
│   └── research/       # 研究模板
│
├── tools/              # 自動化工具
│   ├── python/         # 資料爬取腳本
│   ├── utils/          # 實用工具（AI 分析、連結檢查）
│   └── notebooks/      # Jupyter 筆記本
│
└── Makefile            # 命令快捷鍵
```

**詳細說明：** 各資料夾內都有獨立的 README，說明具體用途與檔案格式

---

## 🔧 常用指令

### 市場資料蒐集

```bash
make fetch-indices           # 爬取全球市場指數快照
make holdings-prices         # 更新持倉價格（儲存當日快照）
make yaml-to-md FILE=analysis/market/2025-12-01.yaml  # 將既有 YAML 轉為 Markdown
```

### 資料收集

```bash
# 下載個股歷史資料
make fetch-market-data SYMBOL=AAPL ARGS="-w 52"

# 設置環境
make setup
```

### 輔助工具

```bash
make check-links        # 檢查 Markdown 連結
make new-analysis TICKER=AAPL NAME="Apple"  # 建立分析資料夾
```

**完整指令列表：** 執行 `make help`

---

## 📖 核心功能詳解

### 🤖 AI 市場分析（已移轉）

每日自動化的市場新聞爬蟲與 AI 報告生成功能已移至 `market-intelligence-system` 專案。若需新聞摘要或每日 AI 報告，請在該專案執行工作流。

### 📊 自動化資料爬取

支援自動爬取：
- 18 個全球市場指數
- Yahoo Finance 股票價格
- 持倉股票的價格追蹤
- 新聞爬蟲已搬到 `market-intelligence-system`

**詳細文檔：** [tools/python/README.md](tools/python/README.md)

### 📑 標準化分析模板

提供多種分析模板：
- 完整估值分析（DCF、相對估值）
- 標準季度分析
- 快速評估模板
- 產業分析模板

**詳細文檔：** [templates/README.md](templates/README.md)

---

## 🎓 新手指南

### 第一次使用

1. **設置環境**
   ```bash
   make setup
   ```

2. **取得市場快照**
   ```bash
   make fetch-indices
   make holdings-prices
   ```
   新聞與 AI 報告請改在 `market-intelligence-system` 執行

3. **設定你的持倉**
   編輯 `portfolio/2025/holdings.md`，參考模板格式

4. **開始分析股票**
   - 從 `templates/analysis/` 選擇合適的模板
   - 複製到 `analysis/2025Q4/TICKER/`
   - 開始撰寫分析

### 建議工作流程

**每日（5 分鐘）**
```bash
make fetch-indices
make holdings-prices
```
查看指數與持倉快照，調整投資決策

**每週（30 分鐘）**
- 回顧本週市場走勢與持倉表現
- 更新 `portfolio/2025/watchlist.md`

**每季（數小時）**
- 對重要持倉完成季度分析
- 更新 `portfolio/2025/performance.md`

---

## 📚 進階資源

### 核心文檔
- [INDEX.md](INDEX.md) - 中央索引，列出所有分析
- [TODO.md](TODO.md) - 待辦事項與改進計畫
- [GIT_GUIDE.md](GIT_GUIDE.md) - Git 使用指南

### 各模組詳細文檔
- [docs/YAML-WORKFLOW.md](docs/YAML-WORKFLOW.md) - YAML 工作流程完整說明 🆕
- [docs/QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md) - 快速參考卡片 🆕
- [analysis/README.md](analysis/2025Q3/README.md) - 分析工作區說明
- [portfolio/README.md](portfolio/README.md) - 投資組合追蹤
- [tools/README.md](tools/README.md) - 自動化工具總覽
- [tools/python/README.md](tools/python/README.md) - Python 爬蟲詳解
- [tools/utils/README.md](tools/utils/README.md) - 實用工具說明
- [templates/README.md](templates/README.md) - 模板使用指南
- [templates/analysis/README.md](templates/analysis/README.md) - YAML 模板系統 🆕

---

## 🆕 最新更新

### 2025-12-03 - 新聞爬蟲與 AI 分析移轉
- 🛠 新聞爬蟲與每日 AI 報告工作流移至 `market-intelligence-system`
- 🧹 移除相關腳本與 Makefile 指令，保留資料抓取與研究模板
- 📄 README 更新，指向新專案的位置

### 2025-12-01 - 文章式報告模板系統
- ✨ 新增結構化報告模板 - 確保格式一致性
- ✨ 優化為自然流暢的文章風格 - 避免冷冰冰的數據堆砌
- ✨ `make daily` 現在使用模板生成結構一致的專業報告
- ✨ 保留 YAML 格式選項 - `make daily-yaml` 適合程式化處理
- 📚 完整說明：[報告模板](templates/analysis/market-daily-article-template.md)
- ⚠️ 此自動化流程已移轉至 `market-intelligence-system`

### 2025-11-21
- ✨ 新增 Claude AI 自動化市場分析系統
- ✨ 一鍵命令 `make daily` 整合完整流程
- ✨ 每日生成 15-20 頁專業市場分析報告
- ✨ 重構工具目錄結構（`tools/utils/`）
- ⚠️ 自動化分析流程已移轉至 `market-intelligence-system`

**更新日誌**: [CHANGELOG-YAML.md](CHANGELOG-YAML.md)

---

## ⚠️ 免責聲明

本知識庫僅供個人研究與紀錄，不構成投資建議。金融市場具高度風險，請依自身風險承受度獨立決策並自行負責。
