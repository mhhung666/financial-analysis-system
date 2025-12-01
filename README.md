# 📊 財報分析知識庫

> 整合財報閱讀、產業研究、投資組合追蹤與資料蒐集的個人研究系統

---

## 🎯 專案簡介

這是一個系統化的投資研究工作流，透過標準化模板與自動化工具，協助你：

- 📈 **每日市場追蹤** - 自動爬取市場資料，AI 生成分析報告
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

### 2️⃣ 每日例行工作（推薦）

```bash
# 一鍵完成每日流程：爬取資料 + AI 分析

# 選項 A: YAML 格式 (新版，推薦) - 結構化數據
make daily-yaml

# 選項 B: Markdown 格式 (舊版) - 直接可讀
make daily
```

這會自動完成：
- ✅ 爬取全球市場指數
- ✅ 爬取持倉股票價格與新聞
- ✅ 使用 Claude AI 生成市場分析報告

輸出結果：
- `data/market-data/2025/Daily/` - 市場資料
- `analysis/market/YYYY-MM-DD.yaml` - 結構化數據 (YAML 格式)
- `analysis/market/YYYY-MM-DD.md` - AI 分析報告 (Markdown 格式)

💡 **YAML 格式優勢**: 結構化數據便於程式處理、數據分析、格式轉換
📚 **詳細說明**: [docs/YAML-WORKFLOW.md](docs/YAML-WORKFLOW.md) | [快速參考](docs/QUICK-REFERENCE.md)

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

### 每日市場追蹤

```bash
# 完整流程（推薦）
make daily-yaml         # YAML 格式（新版，結構化數據）
make daily              # Markdown 格式（舊版，直接可讀）

# 分步執行
make fetch-daily        # 只爬取市場資料
make holdings-prices-daily  # 只更新持倉價格
make analyze-daily-yaml # 只執行 AI 分析（YAML）
make analyze-daily      # 只執行 AI 分析（Markdown）

# 格式轉換
make yaml-to-md FILE=analysis/market/2025-12-01.yaml
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

### 🤖 AI 市場分析系統

每日自動生成 15-20 頁的專業市場分析報告，包含：
- 全球市場總覽與趨勢分析
- 持倉股票深度分析與建議
- 重要新聞解讀
- 風險評估與投資策略

**兩種輸出格式**：
- 📊 **YAML 格式** (新版) - 結構化數據，便於程式處理、數據分析、格式轉換
- 📝 **Markdown 格式** (舊版) - 直接可讀的報告格式

**詳細文檔：**
- [YAML 工作流程](docs/YAML-WORKFLOW.md) - 新版 YAML 格式說明
- [快速參考](docs/QUICK-REFERENCE.md) - 常用指令速查
- [每日分析說明](tools/utils/ANALYZE_DAILY_README.md) - 原有 Markdown 格式

### 📊 自動化資料爬取

支援自動爬取：
- 18 個全球市場指數
- Yahoo Finance 股票價格與新聞
- 持倉股票的價格追蹤

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

2. **執行每日流程**
   ```bash
   make daily
   ```
   查看生成的報告：`analysis/market/YYYY-MM-DD.md`

3. **設定你的持倉**
   編輯 `portfolio/2025/holdings.md`，參考模板格式

4. **開始分析股票**
   - 從 `templates/analysis/` 選擇合適的模板
   - 複製到 `analysis/2025Q4/TICKER/`
   - 開始撰寫分析

### 建議工作流程

**每日（5 分鐘）**
```bash
make daily-yaml  # 自動化完成（推薦 YAML 格式）
# 或
make daily       # 傳統 Markdown 格式
```
查看 AI 分析報告，調整投資決策

**每週（30 分鐘）**
- 回顧本週市場分析報告
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

### 2025-12-01 - YAML 模板系統上線
- ✨ 新增 YAML 模板系統 - 結構化市場分析數據格式
- ✨ `make daily-yaml` - 生成 YAML 格式報告（推薦）
- ✨ YAML → Markdown 轉換工具
- ✨ 數據與呈現分離，便於程式處理和數據分析
- 📚 完整文檔：[YAML-WORKFLOW.md](docs/YAML-WORKFLOW.md)

### 2025-11-21
- ✨ 新增 Claude AI 自動化市場分析系統
- ✨ 一鍵命令 `make daily` 整合完整流程
- ✨ 每日生成 15-20 頁專業市場分析報告
- ✨ 重構工具目錄結構（`tools/utils/`）

**完整更新日誌**: [CHANGELOG-YAML.md](CHANGELOG-YAML.md)

---

## ⚠️ 免責聲明

本知識庫僅供個人研究與紀錄，不構成投資建議。金融市場具高度風險，請依自身風險承受度獨立決策並自行負責。
