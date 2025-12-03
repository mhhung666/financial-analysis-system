# Tools Utilities

通用工具腳本。AI 市場分析腳本已移至 `../market-intelligence-system`，此處僅保留文件維護工具。

## 目錄結構

```
tools/utils/
├── README.md          # 本文件
└── check-links.sh     # Markdown 連結檢查工具
```

## 工具說明

### 🔗 連結檢查工具 (`check-links.sh`)
- 遞迴掃描專案中的 Markdown 檔案
- 檢查內部相對連結與錨點是否有效（自動忽略外部網址）
- 彩色輸出顯示檢查結果

**使用方式**
```bash
make check-links          # 推薦：使用 Makefile
# 或
./tools/utils/check-links.sh
```

## 常見問題

- **Q:** AI 每日分析腳本去哪了？  
  **A:** 已搬到 `market-intelligence-system`，請在該專案執行每日新聞/AI 報告。

- **Q:** 可以新增其他工具嗎？  
  **A:** 可以，將腳本放在此目錄並更新 README，必要時在根目錄 Makefile 加入快捷指令。
