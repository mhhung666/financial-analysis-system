# YAML 工作流程使用指南

本文檔說明如何使用新的 YAML 模板格式生成市場分析報告。

## 📋 概覽

新的工作流程將市場分析報告分為兩個階段:

1. **數據生成階段**: Claude 生成結構化的 YAML 格式數據
2. **呈現階段**: Python 腳本將 YAML 轉換為 Markdown 呈現

### 優勢

✅ **數據與呈現分離**: YAML 專注於數據結構,Markdown 專注於呈現
✅ **程式易處理**: YAML 格式便於程式讀取、驗證、轉換
✅ **格式一致性**: 使用模板確保每次生成的結構一致
✅ **靈活輸出**: 可轉換為多種格式 (Markdown, HTML, PDF, JSON)
✅ **易於驗證**: 使用 JSON Schema 驗證數據完整性

## 🚀 快速開始

### 方式一: 使用 Make 指令 (推薦)

#### 生成 YAML 格式報告

```bash
# 完整流程 (爬取數據 + 生成 YAML 報告)
make daily-yaml

# 或單獨執行分析
make analyze-daily-yaml
```

這會在 `analysis/market/` 目錄下生成 `YYYY-MM-DD.yaml` 檔案。

#### 將 YAML 轉換為 Markdown

```bash
# 轉換今天的報告
make yaml-to-md FILE=analysis/market/2025-12-01.yaml

# 會自動生成 analysis/market/2025-12-01.md
```

### 方式二: 手動執行腳本

#### 1. 生成 YAML 報告

```bash
bash tools/utils/analyze_daily_market_v2.sh
```

#### 2. 轉換為 Markdown

```bash
python3 tools/python/yaml_to_markdown.py \
    analysis/market/2025-12-01.yaml \
    analysis/market/2025-12-01.md
```

## 📁 檔案結構

```
financial-analysis-system/
├── templates/analysis/
│   ├── market-daily-template.yaml    # YAML 模板
│   ├── market-daily-schema.json      # JSON Schema 驗證
│   ├── example-usage.yaml            # 範例檔案
│   └── README.md                      # 模板說明文件
│
├── analysis/market/
│   ├── 2025-12-01.yaml               # 生成的 YAML 數據
│   └── 2025-12-01.md                 # 轉換的 Markdown 報告
│
└── tools/
    ├── utils/
    │   ├── analyze_daily_market.sh       # 舊版 (直接生成 Markdown)
    │   └── analyze_daily_market_v2.sh    # 新版 (生成 YAML)
    └── python/
        └── yaml_to_markdown.py            # YAML → Markdown 轉換器
```

## 🔄 完整工作流程

### 步驟 1: 爬取市場資料

```bash
# 爬取全球指數
make fetch-daily

# 爬取持倉股票價格和新聞
make holdings-prices-daily
```

生成的資料檔案:
- `data/market-data/2025/Daily/global-indices-2025-12-01.md`
- `data/market-data/2025/Daily/prices-2025-12-01.md`
- `data/market-data/2025/News/*-2025-12-01.md`

### 步驟 2: 生成 YAML 報告

```bash
# 使用 Claude 分析數據,生成 YAML
make analyze-daily-yaml
```

這會:
1. 讀取模板檔案 (`templates/analysis/market-daily-template.yaml`)
2. 讀取範例檔案 (`templates/analysis/example-usage.yaml`)
3. 讀取市場數據
4. 生成 Claude 提示詞
5. 調用 Claude API 生成 YAML
6. 保存至 `analysis/market/YYYY-MM-DD.yaml`

### 步驟 3: 轉換為 Markdown

```bash
# 將 YAML 轉換為 Markdown
make yaml-to-md FILE=analysis/market/2025-12-01.yaml
```

這會:
1. 讀取 YAML 檔案
2. 解析數據結構
3. 套用 Markdown 模板
4. 生成格式化的 Markdown 報告
5. 保存至 `analysis/market/YYYY-MM-DD.md`

### 步驟 4: (可選) 驗證 YAML

```bash
# 使用 Python 驗證 YAML 格式
python3 -c "
import yaml
import json
from jsonschema import validate

# 載入 YAML
with open('analysis/market/2025-12-01.yaml') as f:
    data = yaml.safe_load(f)

# 載入 Schema
with open('templates/analysis/market-daily-schema.json') as f:
    schema = json.load(f)

# 驗證
validate(instance=data, schema=schema)
print('✅ YAML 格式驗證通過!')
"
```

## 📊 YAML 結構說明

### 核心區塊

```yaml
metadata:                    # 報告元數據
  report_date: "2025-12-01"
  report_time_utc: "20:50"
  analyst: "AI Financial Analyst"

executive_summary:           # 執行摘要
  market_overview: {...}
  key_metrics: [...]
  risk_assessment: {...}

global_markets:              # 全球市場
  us_market: {...}
  asia_market: {...}
  europe_market: {...}

portfolio_analysis:          # 持倉分析
  overall_performance: {...}
  major_losers: [...]
  strong_gainers: [...]

risk_and_opportunity:        # 風險與機會
  vix_analysis: {...}
  commodities: {...}
  bonds: {...}

investment_strategy:         # 投資策略
  short_term: {...}
  mid_term: {...}
  long_term: {...}

outlook:                     # 後市展望
  key_catalysts: {...}
  scenarios: {...}
```

詳細說明請參考 [templates/analysis/README.md](../templates/analysis/README.md)

## 🎯 使用場景

### 場景一: 每日例行報告

```bash
# 早上執行爬取
make fetch-daily
make holdings-prices-daily

# 分析並生成 YAML
make analyze-daily-yaml

# 轉換為 Markdown 閱讀
make yaml-to-md FILE=analysis/market/$(date +%Y-%m-%d).yaml
```

### 場景二: 程式化處理數據

```python
import yaml

# 讀取 YAML
with open('analysis/market/2025-12-01.yaml') as f:
    data = yaml.safe_load(f)

# 提取特定數據
sp500 = next(
    m for m in data['executive_summary']['key_metrics']
    if m['metric'] == 'S&P 500'
)
print(f"S&P 500: {sp500['value']} ({sp500['change_percent']}%)")

# 分析風險
overall_risk = data['executive_summary']['risk_assessment']['overall_risk_score']
print(f"整體風險評分: {overall_risk}/10")

# 篩選強勢股票
strong_gainers = data['portfolio_analysis']['strong_gainers']
for stock in strong_gainers:
    print(f"{stock['ticker']}: +{stock['change_percent']}%")
```

### 場景三: 批次轉換

```bash
# 將所有 YAML 報告轉換為 Markdown
for yaml_file in analysis/market/*.yaml; do
    make yaml-to-md FILE="$yaml_file"
done
```

### 場景四: 數據驗證

```bash
# 驗證所有 YAML 報告
for yaml_file in analysis/market/*.yaml; do
    echo "驗證: $yaml_file"
    python3 tools/python/validate_yaml.py "$yaml_file"
done
```

## 🔧 進階用途

### 自訂 Markdown 模板

您可以修改 `tools/python/yaml_to_markdown.py` 來自訂輸出格式:

```python
def generate_custom_section(data):
    """自訂章節"""
    md = "## 📊 自訂分析\n\n"
    # 添加您的自訂邏輯
    return md

# 在主函數中調用
markdown += generate_custom_section(data)
```

### 導出為其他格式

```python
import yaml
import json

# 讀取 YAML
with open('analysis/market/2025-12-01.yaml') as f:
    data = yaml.safe_load(f)

# 導出為 JSON
with open('analysis/market/2025-12-01.json', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

# 導出為 CSV (特定數據)
import csv
with open('daily_metrics.csv', 'w') as f:
    writer = csv.writer(f)
    writer.writerow(['Date', 'S&P 500', 'Change%', 'VIX'])

    metrics = data['executive_summary']['key_metrics']
    sp500 = next(m for m in metrics if m['metric'] == 'S&P 500')
    vix = next(m for m in metrics if m['metric'] == 'VIX恐慌指數')

    writer.writerow([
        data['metadata']['report_date'],
        sp500['value'],
        sp500['change_percent'],
        vix['value']
    ])
```

### 時間序列分析

```python
import yaml
from pathlib import Path
import pandas as pd

# 讀取所有 YAML 報告
data_list = []
for yaml_file in Path('analysis/market').glob('*.yaml'):
    with open(yaml_file) as f:
        data = yaml.safe_load(f)
        # 提取關鍵指標
        metrics = {
            'date': data['metadata']['report_date'],
            'sp500': next(m['value'] for m in data['executive_summary']['key_metrics'] if m['metric'] == 'S&P 500'),
            'vix': next(m['value'] for m in data['executive_summary']['key_metrics'] if m['metric'] == 'VIX恐慌指數'),
            'risk_score': data['executive_summary']['risk_assessment']['overall_risk_score']
        }
        data_list.append(metrics)

# 轉換為 DataFrame
df = pd.DataFrame(data_list)
df['date'] = pd.to_datetime(df['date'])
df = df.sort_values('date')

# 分析趨勢
print(df.describe())
print(f"S&P 500 平均值: {df['sp500'].mean():.2f}")
print(f"VIX 平均值: {df['vix'].mean():.2f}")
```

## 💡 最佳實踐

### 1. 保留兩種格式

建議同時保留 YAML 和 Markdown:
- YAML: 用於程式處理、數據分析
- Markdown: 用於人類閱讀、分享報告

### 2. 版本控制

Git 追蹤 YAML 檔案的變更:
```bash
git add analysis/market/*.yaml
git commit -m "feat: add daily market analysis YAML"
```

### 3. 自動化流程

建立 cron job 每日自動執行:
```bash
# 編輯 crontab
crontab -e

# 添加每日 8:00 AM 執行
0 8 * * * cd /path/to/financial-analysis-system && make daily-yaml
```

### 4. 數據備份

定期備份 YAML 檔案:
```bash
# 備份到雲端
rsync -av analysis/market/*.yaml backup@server:/backups/

# 或壓縮備份
tar -czf market-analysis-$(date +%Y%m).tar.gz analysis/market/*.yaml
```

## 🐛 常見問題

### Q1: YAML 格式錯誤

**問題**: Claude 生成的 YAML 無法解析

**解決**:
```bash
# 檢查 YAML 語法
python3 -c "import yaml; yaml.safe_load(open('analysis/market/2025-12-01.yaml'))"

# 如果有錯誤,手動修正或重新生成
make analyze-daily-yaml
```

### Q2: 轉換後的 Markdown 格式不符預期

**解決**: 修改 `tools/python/yaml_to_markdown.py` 自訂格式

### Q3: Claude 未按模板結構生成

**解決**: 檢查提示詞,確保模板和範例都正確傳遞給 Claude

### Q4: 想要切換回舊版 Markdown 格式

**解決**: 使用原始指令
```bash
make analyze-daily  # 直接生成 Markdown
```

## 📚 相關文檔

- [模板說明文件](../templates/analysis/README.md)
- [YAML 模板檔案](../templates/analysis/market-daily-template.yaml)
- [範例檔案](../templates/analysis/example-usage.yaml)
- [JSON Schema](../templates/analysis/market-daily-schema.json)

## 🔄 未來規劃

- [ ] 增加週報 YAML 模板
- [ ] 增加月報 YAML 模板
- [ ] 建立 Web UI 展示 YAML 數據
- [ ] 整合數據視覺化 (圖表生成)
- [ ] 支援多語言輸出

---

**最後更新**: 2025-12-01
**維護者**: Financial Analysis System Team
