.PHONY: help setup fetch-indices holdings-prices fetch-market-data check-links new-analysis yaml-to-md

PYTHON_SETUP_SCRIPT := tools/python/setup.sh
HOLDINGS_PRICES_SCRIPT := tools/python/fetch_holdings_prices.sh
FETCH_INDICES_SCRIPT := tools/python/scrapers/fetch_global_indices.py
FETCH_MARKET_SCRIPT := tools/python/fetch_market_data.sh
CHECK_LINKS_SCRIPT := tools/utils/check-links.sh
NEW_ANALYSIS_SCRIPT := tools/python/new_analysis.py
YAML_TO_MD_SCRIPT := tools/python/yaml_to_markdown.py

help:
	@echo "可用指令："
	@echo "  make setup            # 執行 Python 環境初始化腳本"
	@echo "  make fetch-indices    # 爬取當日全球市場指數"
	@echo "  make holdings-prices  # 分析持倉股票當天價格（不含新聞）"
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

fetch-indices:
	@echo "開始爬取全球市場指數..."
	@python3 $(FETCH_INDICES_SCRIPT)

holdings-prices:
	@echo "開始分析持倉股票價格..."
	@bash $(HOLDINGS_PRICES_SCRIPT)

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
