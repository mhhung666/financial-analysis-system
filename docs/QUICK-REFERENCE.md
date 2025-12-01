# 📋 快速參考 - YAML 工作流程

## 🚀 一鍵指令

### 完整流程 (推薦)

```bash
# YAML 格式 (新版)
make daily-yaml

# Markdown 格式 (舊版)
make daily
```

## 📝 分步執行

### 1. 爬取數據

```bash
make fetch-daily              # 爬取全球指數
make holdings-prices-daily    # 爬取持倉股票
```

### 2. 生成報告

```bash
# 選項 A: YAML 格式 (結構化數據)
make analyze-daily-yaml

# 選項 B: Markdown 格式 (直接可讀)
make analyze-daily
```

### 3. 轉換格式

```bash
# YAML → Markdown
make yaml-to-md FILE=analysis/market/2025-12-01.yaml
```

## 📂 生成的檔案

| 檔案路徑 | 說明 | 用途 |
|---------|------|------|
| `analysis/market/YYYY-MM-DD.yaml` | 結構化數據 | 程式處理 |
| `analysis/market/YYYY-MM-DD.md` | Markdown 報告 | 人類閱讀 |

## 🎯 常用場景

### 場景 1: 每日例行報告

```bash
# 早上執行
make daily-yaml

# 查看報告
cat analysis/market/$(date +%Y-%m-%d).md
```

### 場景 2: 僅更新數據

```bash
make fetch-daily holdings-prices-daily
```

### 場景 3: 重新分析

```bash
# 重新生成今天的報告
make analyze-daily-yaml
```

### 場景 4: 批次轉換

```bash
# 轉換所有 YAML 為 Markdown
for f in analysis/market/*.yaml; do
    make yaml-to-md FILE="$f"
done
```

## 🔧 檔案位置

```
templates/analysis/
├── market-daily-template.yaml    # 模板
├── example-usage.yaml            # 範例
└── README.md                      # 說明

analysis/market/
├── YYYY-MM-DD.yaml               # 數據
└── YYYY-MM-DD.md                 # 報告

tools/
├── utils/analyze_daily_market_v2.sh      # YAML 生成器
└── python/yaml_to_markdown.py            # YAML → MD 轉換器
```

## 💡 提示

- ✅ **YAML 格式**: 適合程式處理、數據分析
- ✅ **Markdown 格式**: 適合閱讀、分享
- ✅ 兩種格式可並存,各取所需

## 🐛 問題排查

| 問題 | 解決方案 |
|------|---------|
| YAML 格式錯誤 | `python3 -c "import yaml; yaml.safe_load(open('FILE'))"` |
| 找不到模板 | 檢查 `templates/analysis/` 目錄 |
| 轉換失敗 | 手動執行: `python3 tools/python/yaml_to_markdown.py FILE` |

## 📚 詳細文檔

- [完整工作流程說明](YAML-WORKFLOW.md)
- [模板使用說明](../templates/analysis/README.md)
- [主要 README](../README.md)

---

**快速幫助**: `make help`
