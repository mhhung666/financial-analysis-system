# Tools Utilities

實用工具腳本集，包含市場分析與系統維護工具。

## 目錄結構

```
tools/utils/
├── README.md                  # 本文件（工具總覽）
├── ANALYZE_DAILY_README.md    # Claude AI 分析系統完整文檔
├── analyze_daily_market.sh    # Claude AI 每日市場分析引擎
└── check-links.sh             # Markdown 連結檢查工具
```

## 工具說明

### 1. 📊 每日市場分析 (`analyze_daily_market.sh`)

**Claude AI 驅動的自動化市場分析系統**

使用 Claude CLI 自動分析每日市場資料，生成專業的投資分析報告。

#### 功能特點
- ✅ 自動整合全球指數、持倉股價、個股新聞
- ✅ 使用 Claude Sonnet 4 進行深度市場分析
- ✅ 生成結構化的 Markdown 分析報告（15-20 頁）
- ✅ 包含持倉建議、風險評估、投資策略

#### 快速使用

```bash
# 推薦：使用 Makefile 執行完整流程
make daily

# 單獨執行分析（需先有當日資料）
make analyze-daily

# 手動執行腳本
./tools/utils/analyze_daily_market.sh
```

#### 輸出位置
- 分析報告：`analysis/market/YYYY-MM-DD.md`

#### 詳細文檔
完整使用說明請參考：[ANALYZE_DAILY_README.md](ANALYZE_DAILY_README.md)

---

### 2. 🔗 連結檢查工具 (`check-links.sh`)

**Markdown 文件連結有效性檢查工具**

自動掃描專案中所有 Markdown 文件，檢查內部連結是否有效。

#### 功能特點
- ✅ 遞迴掃描所有 `.md` 檔案
- ✅ 檢查內部相對連結與絕對連結
- ✅ 自動跳過外部連結（HTTP/HTTPS）
- ✅ 支援錨點連結（`#section`）檢查
- ✅ 彩色輸出顯示檢查結果

#### 快速使用

```bash
# 使用 Makefile（推薦）
make check-links

# 直接執行腳本
./tools/utils/check-links.sh
```

#### 輸出範例

```
========================================
Markdown 連結檢查工具
========================================
專案目錄: /path/to/financial-analysis-system

開始掃描 Markdown 檔案...

❌ 找不到連結
   檔案: README.md
   連結: docs/missing-file.md

========================================
檢查完成
========================================
檢查檔案數: 25
總連結數: 150
失效連結: 1

⚠️  發現 1 個失效連結
```

#### 使用場景
- 重構目錄結構後驗證連結
- Pull Request 前檢查文檔完整性
- 定期維護文檔品質
- CI/CD 流程整合

#### 排除規則
自動排除以下類型的連結：
- 外部網址（`https://`, `http://`）
- Email 連結（`mailto:`）
- 純錨點連結（`#heading`）

---

## 維護指南

### 新增工具腳本

1. 將新腳本放置於 `tools/utils/` 目錄
2. 確保腳本有執行權限：
   ```bash
   chmod +x tools/utils/your-script.sh
   ```
3. 在此 README 中添加說明
4. 在根目錄 Makefile 中添加快捷命令（如需要）
5. 更新相關文檔引用

### 腳本命名規範

- 使用小寫字母和連字符：`my-script.sh`
- Bash 腳本使用 `.sh` 擴展名
- Python 腳本使用 `.py` 擴展名
- 名稱應清楚描述腳本用途

### 文檔更新清單

當移動或新增工具時，確保更新：
- [ ] `tools/utils/README.md` （本文件）
- [ ] `tools/README.md` （工具總覽）
- [ ] `README.md` （專案根目錄）
- [ ] `Makefile` （如有快捷命令）
- [ ] 相關技術文檔（如 ANALYZE_DAILY_README.md）

---

## 常見問題

**Q: 為什麼要將這些腳本放在 utils 目錄？**
A: 為了更好的組織結構，將通用工具腳本與特定語言的工具（如 Python）分開管理。

**Q: 如何在 Makefile 中引用這些腳本？**
A: 使用相對路徑，例如：`tools/utils/script.sh`

**Q: 這些工具是否需要特殊權限？**
A: 大部分工具只需讀取權限。`analyze_daily_market.sh` 需要寫入 `analysis/market/` 目錄的權限。

---

## 相關連結

- [Python 工具說明](../python/README.md)
- [Notebooks 說明](../notebooks/README.md)
- [專案主 README](../../README.md)
- [Claude AI 分析系統文檔](ANALYZE_DAILY_README.md)

---

**最後更新：2025-11-21**
