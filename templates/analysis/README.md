# 市場分析報告模板

此目錄包含標準化的市場分析報告模板,用於生成結構化、一致性高的市場分析報告。

## 📁 檔案說明

### 1. `market-daily-template.yaml`
**用途**: 每日市場分析報告的 YAML 模板

**特點**:
- ✅ 人類可讀性高
- ✅ 結構清晰,層次分明
- ✅ 包含詳細註釋
- ✅ 適合 AI 生成內容時使用
- ✅ 易於版本控制

**使用場景**:
- 生成每日市場分析報告
- 作為 AI 提示詞的結構參考
- 手動編輯和填寫數據

### 2. `market-daily-schema.json`
**用途**: JSON Schema 驗證文件

**特點**:
- ✅ 定義數據結構和類型
- ✅ 提供數據驗證
- ✅ 可與程式整合
- ✅ 確保數據一致性

**使用場景**:
- 驗證生成的報告數據
- 程式開發時的類型定義參考
- API 接口規範

## 📊 模板結構概覽

### 核心區塊

#### 1. **metadata** (元數據)
報告的基本資訊,包括日期、時間、分析師等

#### 2. **executive_summary** (執行摘要)
- `market_overview`: 市場綜述
- `key_metrics`: 關鍵指標 (S&P 500, Dow Jones, Nasdaq, VIX, 黃金, 比特幣)
- `risk_assessment`: 風險評估 (市場/科技/地緣/通膨/集中度風險)

#### 3. **global_markets** (全球市場總覽)
- `us_market`: 美國市場 (五大指數 + 分析)
- `asia_market`: 亞洲市場 (6個主要市場)
- `europe_market`: 歐洲市場 (4個主要市場)
- `market_drivers`: 市場驅動因素 (利多/利空)

#### 4. **portfolio_analysis** (持倉股票分析)
- `overall_performance`: 整體表現統計
- `major_losers`: 重大虧損股票 (跌幅 > 3%)
- `minor_losers`: 輕微下跌股票 (0% ~ -3%)
- `strong_gainers`: 強勢上漲股票 (> 5%)
- `steady_performers`: 穩健表現股票 (0% ~ 5%)
- `position_recommendations`: 持倉建議摘要

#### 5. **news_analysis** (重要新聞解讀)
按產業分類的新聞分析:
- 科技 (Technology)
- 醫療 (Healthcare)
- 金融 (Finance)
- 其他 (Other)

每則新聞包含:
- 標題和摘要
- 影響分析 (正面/負面/中性)
- 受影響的持股

#### 6. **risk_and_opportunity** (風險評估與投資機會)
- `vix_analysis`: VIX 恐慌指數分析
- `commodities`: 商品市場 (黃金/原油/比特幣)
- `bonds`: 債券市場分析
- `risk_matrix`: 風險矩陣 (6大風險類別)

#### 7. **investment_strategy** (投資策略建議)
- `short_term`: 短期策略 (1-2週)
  - 市場觀點
  - 操作重點
  - 具體行動 (買入/賣出/持有)
  - 倉位建議

- `mid_term`: 中期策略 (1-3個月)
  - 市場展望
  - 主題投資
  - 配置調整
  - 觸發式指令

- `long_term`: 長期策略 (6-12個月)
  - 宏觀預期
  - 核心持倉 (55-65%)
  - 衛星持倉 (20-25%)
  - 戰術倉位 (5-10%)
  - 防禦配置 (15-20%)
  - 風險控制

#### 8. **outlook** (後市展望)
- `key_catalysts`: 關鍵催化劑
  - 即將到來的重要事件
  - 正面/負面因素

- `scenarios`: 情境分析
  - 樂觀情境 (機率 + 條件 + 預期 + 策略)
  - 基準情境
  - 悲觀情境

- `future_outlook`: 未來展望
  - 宏觀趨勢
  - 投資主軸

#### 9. **monitoring_indicators** (關鍵監控指標)
- `daily`: 每日監控 (VIX, 殖利率, 美元, 黃金, 原油, 比特幣)
- `weekly`: 每週監控 (經濟數據, 財報, Fed 動態)
- `portfolio_stocks`: 持倉個股監控 (每日/每週/每月)

#### 10. **action_items** (行動清單)
- `immediate`: 立即執行 (本週內)
- `mid_term`: 12月中旬前
- `long_term`: 2026年1月

#### 11. **disclaimer** (免責聲明)
- 法律聲明文字
- 風險警示
- 投資建議

#### 12. **report_metadata** (報告元數據)
- 下次報告日期
- 聯絡方式
- 生成資訊

## 🎯 使用方式

### 方式一: 直接使用 YAML 模板

```bash
# 複製模板
cp templates/analysis/market-daily-template.yaml analysis/market/YYYY-MM-DD.yaml

# 填入數據
# 手動編輯或使用程式生成
```

### 方式二: 作為 AI 提示詞結構

當使用 AI 生成報告時,可以參考此模板結構:

```
請根據以下模板結構,生成 YYYY-MM-DD 的市場分析報告:

1. 執行摘要
   - 市場綜述: [今日市場整體表現]
   - 關鍵指標: [S&P 500, Nasdaq, VIX 等]
   - 風險評估: [各項風險評分]

2. 全球市場總覽
   - 美國市場: [詳細分析]
   - 亞洲市場: [詳細分析]
   - 歐洲市場: [詳細分析]

...
```

### 方式三: 程式整合

```python
import yaml
import json
from jsonschema import validate

# 載入模板
with open('templates/analysis/market-daily-template.yaml') as f:
    template = yaml.safe_load(f)

# 載入 schema
with open('templates/analysis/market-daily-schema.json') as f:
    schema = json.load(f)

# 填入數據
data = template.copy()
data['metadata']['report_date'] = '2025-12-01'
# ... 填入其他數據

# 驗證數據
validate(instance=data, schema=schema)

# 輸出報告
with open('analysis/market/2025-12-01.yaml', 'w') as f:
    yaml.dump(data, f, allow_unicode=True)
```

## 📋 從舊格式遷移

如果您有舊的 Markdown 格式報告,可以使用以下步驟轉換:

1. **識別對應區塊**: 將 Markdown 中的各區塊對應到模板結構
2. **提取數據**: 從 Markdown 表格和文字中提取結構化數據
3. **填入模板**: 將數據填入 YAML 模板
4. **驗證**: 使用 JSON Schema 驗證數據完整性

## 🔄 模板版本

- **v1.0** (2025-12-01)
  - 初始版本
  - 基於現有報告結構去蕪存菁
  - 支援每日市場分析

## 📈 與 Markdown 格式的對照

此 YAML 模板可以轉換為 Markdown 格式呈現:

```
YAML 結構 → Python 程式 → Markdown 報告
```

優點:
- ✅ 數據與呈現分離
- ✅ 易於程式處理
- ✅ 支援多種輸出格式 (Markdown, HTML, PDF)
- ✅ 數據可重複使用

## 🛠️ 最佳實踐

### 1. **保持一致性**
每次生成報告都使用相同的模板結構

### 2. **數據驗證**
使用 JSON Schema 驗證數據完整性

### 3. **版本控制**
使用 Git 追蹤模板變更

### 4. **註釋清楚**
在 YAML 中添加註釋說明各欄位用途

### 5. **定期更新**
根據實際使用情況更新模板結構

## 📝 模板欄位說明

### 風險等級 (0-10)
- 0-2: 低風險
- 3-4: 中低風險
- 5-6: 中等風險
- 7-8: 中高風險
- 9-10: 高風險

### 重要性評級 (1-5 星)
- ⭐: 一般
- ⭐⭐: 次要
- ⭐⭐⭐: 重要
- ⭐⭐⭐⭐: 很重要
- ⭐⭐⭐⭐⭐: 關鍵

### 操作建議
- 🔺 強力加碼
- 🟢 加碼
- 💎 持有
- ⚠️ 觀察
- 🔻 減碼
- ❌ 出清/停損

### VIX 狀態
- < 15: 極度平靜
- 15-20: 正常
- 20-30: 緊張
- > 30: 恐慌

## 🔮 未來計畫

- [ ] 增加週報模板 (`market-weekly-template.yaml`)
- [ ] 增加月報模板 (`market-monthly-template.yaml`)
- [ ] 建立自動轉換工具 (YAML → Markdown)
- [ ] 建立數據視覺化腳本
- [ ] 增加多語言支援

## 📞 支援

如有問題或建議,請:
1. 查看此 README
2. 檢查 YAML 模板註釋
3. 參考現有的報告範例
4. 提交 Issue 或 Pull Request

---

**最後更新**: 2025-12-01
**模板版本**: 1.0
**維護者**: AI Financial Analyst Team
