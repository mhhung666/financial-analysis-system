# 📊 每日市場自動分析系統

## 概述

這個系統使用 **Claude CLI** 自動分析每日市場資料，生成專業的市場分析報告。

## 功能特點

✅ **自動化流程**: 一鍵完成資料爬取 → AI 分析 → 生成報告
✅ **智能分析**: 使用 Claude Sonnet 4 深度分析市場趨勢
✅ **全面整合**: 整合全球指數、持倉股價、個股新聞
✅ **專業報告**: 生成結構化的 Markdown 分析報告

---

## 前置需求

### 1. 安裝 Claude CLI

```bash
# 使用 npm 安裝（推薦）
npm install -g @anthropic-ai/claude-cli

# 或使用 Homebrew (macOS)
brew install claude

# 驗證安裝
claude --version
```

### 2. 配置 Claude API Key

```bash
# 設定環境變數
export ANTHROPIC_API_KEY="your-api-key-here"

# 或在 ~/.bashrc 或 ~/.zshrc 中添加
echo 'export ANTHROPIC_API_KEY="your-api-key-here"' >> ~/.bashrc
```

獲取 API Key: https://console.anthropic.com/

---

## 使用方式

### 完整每日流程（推薦）

執行完整流程，包含資料爬取和 AI 分析：

```bash
make daily
```

這會依序執行：
1. `fetch-daily` - 爬取全球指數與市場新聞
2. `holdings-prices-daily` - 爬取持倉股票價格與新聞
3. `analyze-daily` - 使用 Claude 生成市場分析報告

### 單獨執行分析

如果已經有當日資料，只想重新生成分析：

```bash
make analyze-daily
```

### 手動執行腳本

```bash
./tools/analyze_daily_market.sh
```

---

## 輸出結果

### 分析報告位置

```
analysis/market/YYYY-MM-DD.md
```

例如：`analysis/market/2025-11-21.md`

### 報告結構

生成的分析報告包含以下章節：

1. **📈 市場分析報告標題**
   - 分析時間
   - 市場重點摘要

2. **🌍 全球市場總覽**
   - 各區域市場表現
   - 主要指數漲跌分析

3. **📊 詳細區域分析**
   - 美國市場
   - 亞太市場
   - 歐洲市場
   - VIX 恐慌指數

4. **💼 持倉股票分析**
   - 每支股票的表現
   - 新聞解讀
   - 持倉建議

5. **📰 重要新聞解讀**
   - 影響市場的重大新聞
   - 個股深度分析

6. **💰 商品與債券市場**
   - 黃金、原油、比特幣
   - 美國公債殖利率

7. **🎯 投資策略建議**
   - 風險警示
   - 持倉建議
   - 短期策略
   - 後市展望

8. **📌 總結**
   - 市場整體評估
   - 風險等級評估

---

## 技術細節

### 分析腳本

- **位置**: `tools/analyze_daily_market.sh`
- **語言**: Bash Shell Script
- **AI 模型**: Claude Sonnet 4
- **輸入資料**:
  - 全球指數: `data/market-data/YYYY/Daily/global-indices-YYYY-MM-DD.md`
  - 持倉價格: `data/market-data/YYYY/Daily/prices-YYYY-MM-DD.md`
  - 個股新聞: `data/market-data/YYYY/News/*-YYYY-MM-DD.md`

### 流程圖

```
┌─────────────────────┐
│   make daily        │
└──────────┬──────────┘
           │
           ├─► fetch-daily
           │   └─► 爬取全球指數與市場新聞
           │
           ├─► holdings-prices-daily
           │   └─► 爬取持倉股價與新聞
           │
           └─► analyze-daily
               ├─► 檢查 Claude CLI
               ├─► 收集資料檔案
               ├─► 生成分析提示詞
               ├─► 調用 Claude API
               └─► 保存分析報告
```

---

## 自定義設定

### 修改 AI 模型

編輯 `tools/analyze_daily_market.sh`：

```bash
# 將 sonnet-4 改為其他模型
echo "${prompt}" | ${CLAUDE_CMD} -m opus-4 > "${ANALYSIS_OUTPUT}"
```

可用模型：
- `sonnet-4` - 平衡性能和成本（推薦）
- `opus-4` - 最強大但較貴
- `haiku-4` - 快速且便宜

### 自定義提示詞

編輯 `tools/analyze_daily_market.sh` 中的 `generate_analysis_prompt()` 函數。

---

## 故障排除

### 問題 1: Claude CLI 未安裝

**錯誤訊息**:
```
❌ 錯誤: Claude CLI 未安裝
```

**解決方案**:
```bash
npm install -g @anthropic-ai/claude-cli
```

### 問題 2: API Key 未設定

**錯誤訊息**:
```
Error: ANTHROPIC_API_KEY environment variable not set
```

**解決方案**:
```bash
export ANTHROPIC_API_KEY="your-api-key-here"
```

### 問題 3: 資料檔案不存在

**錯誤訊息**:
```
⚠️ 警告: 以下資料檔案不存在
```

**解決方案**:
先執行資料爬取：
```bash
make fetch-daily
make holdings-prices-daily
```

### 問題 4: 權限錯誤

**錯誤訊息**:
```
Permission denied
```

**解決方案**:
```bash
chmod +x tools/analyze_daily_market.sh
```

---

## 成本估算

使用 Claude Sonnet 4 的成本估算：

- **輸入**: ~50,000 tokens（全球指數 + 持倉價格 + 15 支股票新聞）
- **輸出**: ~10,000 tokens（完整分析報告）
- **估算成本**: $0.15 - 0.30 美元/次

建議每日執行一次，月成本約 $5-10 美元。

---

## 範例輸出

查看範例分析報告：

```bash
cat analysis/market/2025-11-21.md
```

---

## 進階功能

### 批次分析歷史資料

如果你有多天的歷史資料想要重新分析：

```bash
# 指定日期分析（需修改腳本支援日期參數）
./tools/analyze_daily_market.sh 2025-11-20
```

### 整合到 Cron 定時任務

每天自動執行：

```bash
# 編輯 crontab
crontab -e

# 添加每天 18:00 執行
0 18 * * * cd /path/to/financial-report-analysis && make daily
```

---

## 常見問題 (FAQ)

**Q: 分析一次需要多久？**
A: 通常 2-5 分鐘，取決於當天的新聞數量和網路速度。

**Q: 可以分析特定股票嗎？**
A: 目前分析所有持倉股票，未來可擴展為指定股票分析。

**Q: 報告語言可以改成英文嗎？**
A: 可以，修改提示詞中的語言要求即可。

**Q: 支援其他 AI 模型嗎？**
A: 目前僅支援 Claude，但可以修改腳本以支援 OpenAI GPT 或其他模型。

---

## 更新日誌

### v1.0.0 (2025-11-21)
- ✨ 初始版本
- ✅ 支援全自動每日市場分析
- ✅ 整合 Claude Sonnet 4
- ✅ 生成專業 Markdown 報告

---

## 貢獻

歡迎提交 Issue 或 Pull Request 改進此工具！

---

## 授權

MIT License

---

**Happy Analyzing! 📈💰**
