.PHONY: help setup daily fetch-daily holdings-prices-daily analyze-daily fetch-market-data check-links new-analysis

PYTHON_SETUP_SCRIPT := tools/python/setup.sh
FETCH_DAILY_SCRIPT := tools/python/fetch_daily_market_news.sh
HOLDINGS_PRICES_SCRIPT := tools/python/fetch_holdings_prices.sh
ANALYZE_DAILY_SCRIPT := tools/utils/analyze_daily_market.sh
FETCH_MARKET_SCRIPT := tools/python/fetch_market_data.sh
CHECK_LINKS_SCRIPT := tools/utils/check-links.sh
NEW_ANALYSIS_SCRIPT := tools/python/new_analysis.py

help:
	@echo "可用指令："
	@echo "  make setup            # 執行 Python 環境初始化腳本"
	@echo "  make daily            # 執行每日完整流程 (爬取資料 + Claude 分析)"
	@echo "  make fetch-daily      # 爬取當日全球指數與市場新聞"
	@echo "  make holdings-prices-daily # 分析持倉股票當天價格 + 爬取所有持股新聞"
	@echo "  make analyze-daily    # 使用 Claude CLI 分析當日市場資料"
	@echo "  make fetch-market-data SYMBOL=UPS [ARGS=\"...\"]"
	@echo "                        # 下載單一股票/匯率的歷史資料"
	@echo "  make check-links      # 檢查 Markdown 連結是否有效"
	@echo "  make new-analysis TICKER=AAPL NAME=\"Apple Inc.\" [QUARTER=2025Q4] [INDUSTRY=\"科技\"]"
	@echo "                        # 建立新的季度報告分析資料夾"

setup:
	@echo "執行 Python 環境設定..."
	@bash $(PYTHON_SETUP_SCRIPT)

daily: fetch-daily holdings-prices-daily analyze-daily
	@echo "✅ 每日完整流程執行完成！"

fetch-daily:
	@echo "開始每日市場資料與新聞爬取..."
	@bash $(FETCH_DAILY_SCRIPT)

holdings-prices-daily:
	@echo "開始分析持倉股票價格與新聞..."
	@bash $(HOLDINGS_PRICES_SCRIPT) --news

analyze-daily:
	@echo "開始使用 Claude 分析當日市場..."
	@bash $(ANALYZE_DAILY_SCRIPT)

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
