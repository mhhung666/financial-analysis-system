.PHONY: help setup daily daily-yaml fetch-daily holdings-prices-daily analyze-daily analyze-daily-yaml analyze-weekly fetch-market-data check-links new-analysis yaml-to-md

PYTHON_SETUP_SCRIPT := tools/python/setup.sh
FETCH_DAILY_SCRIPT := tools/python/fetch_daily_market_news.sh
HOLDINGS_PRICES_SCRIPT := tools/python/fetch_holdings_prices.sh
ANALYZE_DAILY_SCRIPT := tools/utils/analyze_daily_market.sh
ANALYZE_DAILY_YAML_SCRIPT := tools/utils/analyze_daily_market_v2.sh
ANALYZE_WEEKLY_SCRIPT := tools/utils/analyze_weekly_market.sh
FETCH_MARKET_SCRIPT := tools/python/fetch_market_data.sh
CHECK_LINKS_SCRIPT := tools/utils/check-links.sh
NEW_ANALYSIS_SCRIPT := tools/python/new_analysis.py
YAML_TO_MD_SCRIPT := tools/python/yaml_to_markdown.py

help:
	@echo "可用指令："
	@echo "  make setup            # 執行 Python 環境初始化腳本"
	@echo "  make daily            # 執行每日完整流程 (爬取資料 + Claude 分析 Markdown)"
	@echo "  make daily-yaml       # 執行每日完整流程 (爬取資料 + Claude 分析 YAML)"
	@echo "  make fetch-daily      # 爬取當日全球指數與市場新聞"
	@echo "  make holdings-prices-daily # 分析持倉股票當天價格 + 爬取所有持股新聞"
	@echo "  make analyze-daily    # 使用 Claude CLI 分析當日市場資料 (Markdown 格式)"
	@echo "  make analyze-daily-yaml # 使用 Claude CLI 分析當日市場資料 (YAML 格式)"
	@echo "  make analyze-weekly   # 使用 Claude CLI 分析上週市場資料與氛圍"
	@echo "  make yaml-to-md FILE=analysis/market/YYYY-MM-DD.yaml"
	@echo "                        # 將 YAML 報告轉換為 Markdown 格式"
	@echo "  make fetch-market-data SYMBOL=UPS [ARGS=\"...\"]"
	@echo "                        # 下載單一股票/匯率的歷史資料"
	@echo "  make check-links      # 檢查 Markdown 連結是否有效"
	@echo "  make new-analysis TICKER=AAPL NAME=\"Apple Inc.\" [QUARTER=2025Q4] [INDUSTRY=\"科技\"]"
	@echo "                        # 建立新的季度報告分析資料夾"

setup:
	@echo "執行 Python 環境設定..."
	@bash $(PYTHON_SETUP_SCRIPT)

daily: fetch-daily holdings-prices-daily analyze-daily
	@echo "✅ 每日完整流程執行完成 (Markdown 格式)！"

daily-yaml: fetch-daily holdings-prices-daily analyze-daily-yaml
	@echo "✅ 每日完整流程執行完成 (YAML 格式)！"

fetch-daily:
	@echo "開始每日市場資料與新聞爬取..."
	@bash $(FETCH_DAILY_SCRIPT)

holdings-prices-daily:
	@echo "開始分析持倉股票價格與新聞..."
	@bash $(HOLDINGS_PRICES_SCRIPT) --news

analyze-daily:
	@echo "開始使用 Claude 分析當日市場 (Markdown 格式)..."
	@bash $(ANALYZE_DAILY_SCRIPT)

analyze-daily-yaml:
	@echo "開始使用 Claude 分析當日市場 (YAML 格式)..."
	@bash $(ANALYZE_DAILY_YAML_SCRIPT)

analyze-weekly:
	@echo "開始使用 Claude 分析上週市場氛圍..."
	@bash $(ANALYZE_WEEKLY_SCRIPT)

yaml-to-md:
	@if [ -z "$(FILE)" ]; then \
		echo "請提供 YAML 檔案路徑，例如:"; \
		echo "  make yaml-to-md FILE=analysis/market/2025-12-01.yaml"; \
		exit 1; \
	fi
	@if [ ! -f "$(FILE)" ]; then \
		echo "❌ 錯誤: 找不到檔案 $(FILE)"; \
		exit 1; \
	fi
	@echo "轉換 YAML 為 Markdown: $(FILE)"
	@python3 $(YAML_TO_MD_SCRIPT) "$(FILE)" "$${FILE%.yaml}.md"

fetch-market-data:
	@if [ -z "$(SYMBOL)" ]; then \
		echo "請使用 SYMBOL=股票代碼，例如: make fetch-market-data SYMBOL=UPS"; \
		exit 1; \
	fi
	@echo "開始爬取 $(SYMBOL) 的市場資料..."
	@$(FETCH_MARKET_SCRIPT) $(SYMBOL) $(ARGS)

check-links:
	@echo "檢查 Markdown 連結..."
	@bash $(CHECK_LINKS_SCRIPT)

new-analysis:
	@if [ -z "$(TICKER)" ] || [ -z "$(NAME)" ]; then \
		echo "請提供 TICKER 和 NAME，例如:"; \
		echo "  make new-analysis TICKER=AAPL NAME=\"Apple Inc.\""; \
		echo "  make new-analysis TICKER=MSFT NAME=\"Microsoft\" QUARTER=2025Q4 INDUSTRY=\"雲端運算\""; \
		exit 1; \
	fi
	@echo "建立新分析報告: $(TICKER) - $(NAME)..."
	@python3 $(NEW_ANALYSIS_SCRIPT) $(TICKER) "$(NAME)" \
		$(if $(QUARTER),--quarter $(QUARTER)) \
		$(if $(INDUSTRY),--industry "$(INDUSTRY)")
