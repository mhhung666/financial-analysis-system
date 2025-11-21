# 模板目錄

此目錄包含各種財務分析、研究和資料組織任務的模板。

## 目錄結構

```
templates/
├── analysis/                      # 股票分析模板
│   ├── full-valuation.md             # 完整DCF估值
│   ├── standard-analysis.md          # 標準季度股票分析
│   ├── quick-review.md               # 快速篩選模板
│   └── industry-analysis.md          # 產業層級分析
│
├── data/                          # 公司資料模板
│   └── company-profile.md            # 公司基本資料檔案
│
├── research/                      # 研究與學習模板
│   ├── framework-template.md         # 投資框架文件
│   ├── concept-template.md           # 投資概念筆記
│   └── industry-note-template.md     # 產業研究筆記
│
├── comparisons/                   # 同業比較模板
│   └── peer-comparison-template.md   # 多公司比較
│
└── README.md                      # 本文件
```

## 模板類別

### 📊 分析模板
在分析個股或產業時使用這些模板:
- **full-valuation.md**: 完整財務建模的深度DCF估值
- **standard-analysis.md**: 標準季度獲利審查與分析
- **quick-review.md**: 初步投資評估的快速篩選
- **industry-analysis.md**: 類別/產業層級分析

**使用時機**: 分析特定股票或進行獲利審查時

### 📁 資料模板
使用這些模板組織公司基本資訊:
- **company-profile.md**: 完整的公司資料檔案,包括財務、管理層、產品和競爭地位

**使用時機**: 在 `/data/` 目錄中建立公司參考文件時

### 🔬 研究模板
使用這些模板記錄投資知識和框架:
- **framework-template.md**: 記錄投資框架(例如: DCF方法論、波特五力分析)
- **concept-template.md**: 記錄投資概念(例如: 網絡效應、規模經濟)
- **industry-note-template.md**: 記錄產業特定知識和趨勢

**使用時機**: 在 `/research/` 中建立投資知識庫時

### 🔄 比較模板
使用這些模板比較多家公司:
- **peer-comparison-template.md**: 競爭對手的並排比較,包含評分和排名

**使用時機**: 評估同類別的多家公司以決定最佳投資標的時

## 使用指南

### 開始新分析
1. **確定類型**: 決定哪個模板符合您的需求
2. **複製模板**: 基於模板建立新文件
3. **遵循命名慣例**: 使用一致的命名(見下文)
4. **填寫各節**: 完成所有相關章節
5. **保存到適當位置**: 遵循目錄結構指南

### 命名慣例

**股票分析**:
- 格式: `[股票代號]_[YYYY]Q[Q]_[類型].md`
- 範例: `AAPL_2025Q3_full-valuation.md`
- 保存至: `/reports/[YYYY]Q[Q]/`

**公司檔案**:
- 格式: `[股票代號]_profile.md`
- 範例: `AAPL_profile.md`
- 保存至: `/data/company-profiles/`

**同業比較**:
- 格式: `[產業名稱]-comparison.md`
- 範例: `digital-ad-platforms-comparison.md`
- 保存至: `/comparisons/`

**研究筆記**:
- 格式: `[主題名稱].md`
- 範例: `dcf-methodology.md`, `network-effects.md`
- 保存至: `/research/frameworks/`, `/research/concepts/`, 或 `/research/industries/`

## 工作流程範例

### 範例 1: 分析新股票
```
1. 從 quick-review.md 開始 → 初步篩選
2. 如果有前景 → 使用 standard-analysis.md → 季度分析
3. 如果非常有前景 → 使用 full-valuation.md → 深度DCF估值
4. 建立 company-profile.md → /data/ 中的參考文件
```

### 範例 2: 類別研究
```
1. 使用 industry-note-template.md → 記錄類別知識
2. 使用 peer-comparison-template.md → 比較主要參與者
3. 使用分析模板 → 深入研究首選標的
```

### 範例 3: 建立知識庫
```
1. 使用 framework-template.md → 記錄DCF、波特五力分析等
2. 使用 concept-template.md → 記錄護城河、單位經濟等
3. 進行實際分析時參考這些文件
```

## 最佳實踐

1. **始終從模板開始**: 不要從頭開始建立分析文件
2. **保持一致性**: 在所有分析中使用相同結構以便比較
3. **定期更新**: 保持模板和分析內容為最新資訊
4. **連結文件**: 交叉參照相關分析、比較和研究筆記
5. **歸檔舊版本**: 更新時,保存先前版本以供歷史參考
6. **使用視覺輔助**: 在有幫助的地方加入圖表、表格和圖解
7. **徹底完整**: 完成所有相關章節;僅在真正不適用時才跳過

## 模板客製化

可隨意根據您的特定需求客製化模板:
- 為特定產業添加相關章節
- 移除不適用於您分析風格的章節
- 根據您的偏好調整指標和比率
- 為重複性分析類型建立新模板

**重要**: 保持核心結構完整以確保分析之間的一致性。
