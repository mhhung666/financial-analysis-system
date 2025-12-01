# 更新日誌 - YAML 工作流程

## 📅 2025-12-01 - YAML 模板系統上線

### 🎉 新增功能

#### 1. YAML 模板系統
- ✅ 建立標準化的 YAML 模板 (`templates/analysis/market-daily-template.yaml`)
- ✅ 提供 JSON Schema 驗證 (`templates/analysis/market-daily-schema.json`)
- ✅ 包含詳細的使用範例 (`templates/analysis/example-usage.yaml`)
- ✅ 完整的模板說明文檔 (`templates/analysis/README.md`)

#### 2. 新版生成腳本
- ✅ `tools/utils/analyze_daily_market_v2.sh` - 生成 YAML 格式報告
- ✅ 讀取模板結構,確保輸出一致性
- ✅ 提供範例參考,提升 Claude 生成品質
- ✅ 自動後處理,清理格式

#### 3. YAML 轉 Markdown 工具
- ✅ `tools/python/yaml_to_markdown.py` - 轉換工具
- ✅ 支援完整的報告結構轉換
- ✅ 保持格式美觀和可讀性
- ✅ 自動化處理表格、列表、emoji

#### 4. Makefile 整合
- ✅ `make daily-yaml` - YAML 格式完整流程
- ✅ `make analyze-daily-yaml` - 單獨生成 YAML
- ✅ `make yaml-to-md FILE=...` - 格式轉換
- ✅ 保留原有 `make daily` 指令 (Markdown 格式)

#### 5. 文檔
- ✅ [YAML-WORKFLOW.md](docs/YAML-WORKFLOW.md) - 完整工作流程說明
- ✅ [QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md) - 快速參考卡片
- ✅ 本更新日誌

### 🎯 主要優勢

#### 數據與呈現分離
```
資料來源 → YAML (結構化數據) → Markdown/HTML/PDF (呈現層)
```

#### 一致性保證
- 使用模板確保每次生成的結構一致
- JSON Schema 驗證數據完整性
- 避免格式不一致的問題

#### 程式易處理
```python
import yaml

# 讀取數據
with open('analysis/market/2025-12-01.yaml') as f:
    data = yaml.safe_load(f)

# 提取任意數據
sp500 = data['executive_summary']['key_metrics'][0]
```

#### 靈活輸出
- 同一份 YAML 可轉換為多種格式
- Markdown (閱讀)
- JSON (API)
- HTML (網頁)
- PDF (報告)
- CSV (數據分析)

### 📊 模板結構

#### 核心區塊 (12 個主要區塊)

1. **metadata** - 報告元數據
2. **executive_summary** - 執行摘要
   - market_overview
   - key_metrics (6 項)
   - risk_assessment (5 類風險)
3. **global_markets** - 全球市場總覽
   - us_market (5 個指數)
   - asia_market (6 個市場)
   - europe_market (4 個市場)
   - market_drivers (利多/利空)
4. **portfolio_analysis** - 持倉股票分析
   - overall_performance
   - 按漲跌分類 (major_losers, minor_losers, strong_gainers, steady_performers)
   - position_recommendations
5. **news_analysis** - 重要新聞解讀
   - 按產業分類 (technology, healthcare, finance, other)
6. **risk_and_opportunity** - 風險評估與投資機會
   - vix_analysis
   - commodities (gold, oil, bitcoin)
   - bonds
   - risk_matrix
7. **investment_strategy** - 投資策略建議
   - short_term (1-2週)
   - mid_term (1-3個月)
   - long_term (6-12個月)
8. **outlook** - 後市展望
   - key_catalysts
   - scenarios (bullish, base, bearish)
   - future_outlook
9. **monitoring_indicators** - 關鍵監控指標
   - daily (6 項)
   - weekly (經濟數據, 財報, Fed 動態)
   - portfolio_stocks
10. **action_items** - 行動清單
    - immediate (本週內)
    - mid_term (月中前)
    - long_term (長期)
11. **disclaimer** - 免責聲明
12. **report_metadata** - 報告元數據

### 🔄 工作流程對比

#### 舊版流程 (Markdown)
```bash
爬取數據 → Claude 分析 → 直接生成 Markdown
```

優點:
- ✅ 簡單直接
- ✅ 一步到位

缺點:
- ❌ 格式可能不一致
- ❌ 難以程式處理
- ❌ 無法轉換為其他格式

#### 新版流程 (YAML)
```bash
爬取數據 → Claude 分析 → YAML 數據 → 轉換為 Markdown
```

優點:
- ✅ 結構化,一致性高
- ✅ 易於程式處理
- ✅ 可轉換為多種格式
- ✅ 數據可驗證

缺點:
- ⚠️ 多一個轉換步驟

### 📝 使用範例

#### 每日例行報告

```bash
# 方式一: 一鍵執行 (YAML)
make daily-yaml

# 方式二: 分步執行
make fetch-daily
make holdings-prices-daily
make analyze-daily-yaml
make yaml-to-md FILE=analysis/market/$(date +%Y-%m-%d).yaml
```

#### 程式化數據處理

```python
import yaml
from pathlib import Path

# 讀取最新報告
latest_yaml = sorted(Path('analysis/market').glob('*.yaml'))[-1]
with open(latest_yaml) as f:
    data = yaml.safe_load(f)

# 提取關鍵指標
metrics = data['executive_summary']['key_metrics']
for metric in metrics:
    print(f"{metric['metric']}: {metric['value']} ({metric['change_percent']}%)")

# 分析風險
risk_score = data['executive_summary']['risk_assessment']['overall_risk_score']
print(f"整體風險: {risk_score}/10")
```

#### 批次轉換

```bash
# 將所有 YAML 轉換為 Markdown
for yaml_file in analysis/market/*.yaml; do
    python3 tools/python/yaml_to_markdown.py "$yaml_file" "${yaml_file%.yaml}.md"
done
```

### 🎓 遷移指南

#### 從舊版遷移到新版

1. **保留舊版**: 舊版腳本仍然可用 (`make daily`)
2. **嘗試新版**: 使用 `make daily-yaml` 生成 YAML
3. **對比驗證**: 比較兩種格式的輸出
4. **逐步切換**: 確認新版符合需求後完全切換

#### 兩種格式並存

```bash
# 同時生成兩種格式
make daily          # Markdown
make daily-yaml     # YAML

# 比較差異
diff analysis/market/2025-12-01.md \
     <(python3 tools/python/yaml_to_markdown.py analysis/market/2025-12-01.yaml)
```

### 🛠️ 技術細節

#### 文件清單

| 檔案 | 用途 | 說明 |
|------|------|------|
| `templates/analysis/market-daily-template.yaml` | YAML 模板 | 定義報告結構 |
| `templates/analysis/market-daily-schema.json` | JSON Schema | 驗證數據格式 |
| `templates/analysis/example-usage.yaml` | 範例 | 展示如何填寫 |
| `templates/analysis/README.md` | 文檔 | 模板使用說明 |
| `tools/utils/analyze_daily_market_v2.sh` | Shell 腳本 | 生成 YAML |
| `tools/python/yaml_to_markdown.py` | Python 腳本 | YAML → MD |
| `docs/YAML-WORKFLOW.md` | 文檔 | 工作流程說明 |
| `docs/QUICK-REFERENCE.md` | 文檔 | 快速參考 |

#### 依賴

- Python 3.7+
- PyYAML (`pip install pyyaml`)
- jsonschema (`pip install jsonschema`)
- Claude CLI

### 📈 未來規劃

#### 短期 (1-2 週)
- [ ] 測試新版流程穩定性
- [ ] 收集用戶反饋
- [ ] 修復發現的問題
- [ ] 優化轉換腳本

#### 中期 (1 個月)
- [ ] 增加週報 YAML 模板
- [ ] 增加月報 YAML 模板
- [ ] 建立數據驗證工具
- [ ] 增加更多輸出格式 (HTML, PDF)

#### 長期 (3 個月)
- [ ] Web UI 展示 YAML 數據
- [ ] 整合數據視覺化 (圖表)
- [ ] 時間序列分析工具
- [ ] 自動化報告分發

### 🙏 致謝

感謝所有參與測試和提供反饋的用戶!

### 📞 支援

如有問題:
1. 查看 [YAML-WORKFLOW.md](docs/YAML-WORKFLOW.md)
2. 查看 [QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md)
3. 查看 [templates/analysis/README.md](templates/analysis/README.md)
4. 提交 Issue

---

**版本**: 1.0.0
**發布日期**: 2025-12-01
**維護者**: Financial Analysis System Team
