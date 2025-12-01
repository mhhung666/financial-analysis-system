#!/usr/bin/env python3
"""
YAML 市場分析報告轉換為 Markdown 格式

用途: 將結構化的 YAML 市場分析報告轉換為易讀的 Markdown 格式
作者: Financial Analysis System
"""

import yaml
import sys
from datetime import datetime
from pathlib import Path


def format_percentage(value):
    """格式化百分比數值"""
    if value > 0:
        return f"+{value:.2f}%"
    else:
        return f"{value:.2f}%"


def format_currency(value, currency="USD"):
    """格式化貨幣數值"""
    if currency == "USD":
        if value >= 1000:
            return f"${value:,.2f}"
        else:
            return f"${value:.2f}"
    return f"{value:.2f}"


def generate_markdown_header(data):
    """生成 Markdown 報告標題"""
    metadata = data.get('metadata', {})
    summary = data.get('executive_summary', {}).get('market_overview', {})

    report_date = metadata.get('report_date', 'N/A')
    report_time = metadata.get('report_time_utc', 'N/A')
    analyst = metadata.get('analyst', 'AI Financial Analyst')

    md = f"""# 📈 市場分析報告 - {report_date}

> **報告生成時間**: {report_date} {report_time} UTC
> **分析師**: {analyst}
> **報告類型**: 每日市場分析

---

"""
    return md


def generate_executive_summary(data):
    """生成執行摘要"""
    summary = data.get('executive_summary', {})

    md = """## 📊 執行摘要

### 市場綜述

"""

    # 市場概況
    overview = summary.get('market_overview', {})
    md += f"{overview.get('description', 'N/A')}\n\n"

    # 關鍵數據
    md += "### 關鍵數據\n\n"
    md += "| 指標 | 數值 | 變化 | 狀態 |\n"
    md += "|------|------|------|------|\n"

    for metric in summary.get('key_metrics', []):
        metric_name = metric.get('metric', 'N/A')
        value = metric.get('value', 0)
        change = format_percentage(metric.get('change_percent', 0))
        status = metric.get('status', 'N/A')
        emoji = metric.get('emoji', '🟡')

        # 格式化數值
        if 'currency' in metric:
            value_str = format_currency(value, metric['currency'])
        else:
            value_str = f"{value:,.2f}"

        md += f"| **{metric_name}** | {value_str} | {change} | {emoji} {status} |\n"

    # 風險等級評估
    md += "\n### 風險等級評估\n\n"
    md += "| 類別 | 等級 | 說明 |\n"
    md += "|------|------|------|\n"

    risk = summary.get('risk_assessment', {})

    risk_items = [
        ('整體市場風險', 'overall_market_risk'),
        ('科技股風險', 'tech_stock_risk'),
        ('地緣政治風險', 'geopolitical_risk'),
        ('通膨風險', 'inflation_risk'),
        ('持倉集中度風險', 'concentration_risk')
    ]

    for name, key in risk_items:
        item = risk.get(key, {})
        level = item.get('level', 0)
        desc = item.get('description', 'N/A')
        md += f"| **{name}** | ⚠️ {level}/10 | {desc} |\n"

    overall_score = risk.get('overall_risk_score', 0)
    md += f"\n**綜合風險評分**: **{overall_score:.1f}/10**\n\n"
    md += "---\n\n"

    return md


def generate_global_markets(data):
    """生成全球市場總覽"""
    markets = data.get('global_markets', {})

    md = """## 🌍 全球市場總覽

### 1.1 美國市場 🇺🇸

**主要指數表現**

| 指數 | 收盤價 | 漲跌幅 | 成交量 | 技術狀態 |
|------|--------|--------|--------|----------|
"""

    # 美國市場指數
    us_market = markets.get('us_market', {})
    for index in us_market.get('indices', []):
        name = index.get('name', 'N/A')
        close = index.get('close', 0)
        change = format_percentage(index.get('change_percent', 0))
        volume = index.get('volume', 'N/A')
        status = index.get('technical_status', 'N/A')

        emoji = "🟢" if index.get('change_percent', 0) > 0 else "🔴" if index.get('change_percent', 0) < 0 else "🟡"

        md += f"| {name} | {close:,.2f} | {emoji} {change} | {volume} | {status} |\n"

    # 美國市場分析
    md += "\n**市場分析**：\n"
    analysis = us_market.get('market_analysis', {})
    for driver in analysis.get('drivers', []):
        md += f"- {driver}\n"

    # 亞洲市場
    md += "\n### 1.2 亞洲市場 🌏\n\n"
    md += "**主要市場表現**\n\n"
    md += "| 市場 | 指數 | 收盤價 | 漲跌幅 | 成交量 |\n"
    md += "|------|------|--------|--------|--------|\n"

    asia_market = markets.get('asia_market', {})
    for index in asia_market.get('indices', []):
        country = index.get('country', 'N/A')
        name = index.get('name', 'N/A')
        close = index.get('close', 0)
        change = format_percentage(index.get('change_percent', 0))
        volume = index.get('volume', 'N/A')

        emoji = "🟢" if index.get('change_percent', 0) > 0 else "🔴" if index.get('change_percent', 0) < 0 else "🟡"

        # 根據國家添加國旗
        flag_map = {
            '日本': '🇯🇵',
            '韓國': '🇰🇷',
            '台灣': '🇹🇼',
            '中國': '🇨🇳',
            '香港': '🇭🇰',
            '新加坡': '🇸🇬'
        }
        flag = flag_map.get(country, '🌏')

        md += f"| {flag} {country} | {name} | {close:,.2f} | {emoji} {change} | {volume} |\n"

    md += f"\n**亞洲市場分析**：\n{asia_market.get('analysis', 'N/A')}\n\n"

    # 歐洲市場
    md += "### 1.3 歐洲市場 🇪🇺\n\n"
    md += "**主要市場表現**\n\n"
    md += "| 市場 | 指數 | 收盤價 | 漲跌幅 |\n"
    md += "|------|------|--------|--------|\n"

    europe_market = markets.get('europe_market', {})
    for index in europe_market.get('indices', []):
        country = index.get('country', '歐洲')
        name = index.get('name', 'N/A')
        close = index.get('close', 0)
        change = format_percentage(index.get('change_percent', 0))

        emoji = "🟢" if index.get('change_percent', 0) > 0 else "🔴" if index.get('change_percent', 0) < 0 else "🟡"

        # 國旗
        flag_map = {
            '德國': '🇩🇪',
            '法國': '🇫🇷',
            '英國': '🇬🇧',
            '歐洲': '🇪🇺'
        }
        flag = flag_map.get(country, '🇪🇺')

        md += f"| {flag} {country} | {name} | {close:,.2f} | {emoji} {change} |\n"

    md += f"\n**歐洲市場分析**：\n{europe_market.get('analysis', 'N/A')}\n\n"

    # 市場驅動因素
    md += "### 1.4 市場驅動因素總結\n\n"
    drivers = markets.get('market_drivers', {})

    md += "**上漲動力** ✅\n"
    for i, factor in enumerate(drivers.get('bullish_factors', []), 1):
        md += f"{i}. {factor}\n"

    md += "\n**下行風險** ⚠️\n"
    for i, factor in enumerate(drivers.get('bearish_factors', []), 1):
        md += f"{i}. {factor}\n"

    md += "\n---\n\n"

    return md


def generate_portfolio_analysis(data):
    """生成持倉股票分析"""
    portfolio = data.get('portfolio_analysis', {})

    md = """## 📈 持倉股票分析

### 2.1 持倉股票整體表現

**績效統計**

| 指標 | 數值 |
|------|------|
"""

    perf = portfolio.get('overall_performance', {})
    md += f"| 總持股數 | {perf.get('total_holdings', 0)} 檔 |\n"
    md += f"| 上漲股票 | 🟢 {perf.get('stocks_up', 0)} 檔 ({perf.get('win_rate_percent', 0):.1f}%) |\n"
    md += f"| 下跌股票 | 🔴 {perf.get('stocks_down', 0)} 檔 |\n"
    md += f"| 平均漲跌幅 | {format_percentage(perf.get('average_change_percent', 0))} |\n"

    best = perf.get('best_performer', {})
    worst = perf.get('worst_performer', {})
    md += f"| 最大漲幅 | {best.get('ticker', 'N/A')} {format_percentage(best.get('change_percent', 0))} |\n"
    md += f"| 最大跌幅 | {worst.get('ticker', 'N/A')} {format_percentage(worst.get('change_percent', 0))} |\n"

    # 各類股票
    if portfolio.get('major_losers'):
        md += "\n### 2.2 重大虧損股票 (跌幅 > 3%) ❌\n\n"
        md += generate_stock_table(portfolio.get('major_losers', []))
    else:
        md += "\n### 2.2 重大虧損股票 (跌幅 > 3%) ❌\n\n**無重大虧損股票**\n\n"

    if portfolio.get('minor_losers'):
        md += "### 2.3 輕微下跌股票 (0% ~ -3%) ⚠️\n\n"
        md += generate_stock_table(portfolio.get('minor_losers', []))

    if portfolio.get('strong_gainers'):
        md += "### 2.4 強勢上漲股票 (+5%以上) 🚀\n\n"
        md += generate_stock_table(portfolio.get('strong_gainers', []))

    if portfolio.get('steady_performers'):
        md += "### 2.5 穩健表現股票 (+0% ~ +5%) 📊\n\n"
        md += generate_stock_table(portfolio.get('steady_performers', []))

    md += "\n---\n\n"

    return md


def generate_stock_table(stocks):
    """生成股票表格"""
    md = "| 股票 | 當前價格 | 漲跌幅 | 持倉建議 | 分析 |\n"
    md += "|------|----------|--------|----------|------|\n"

    for stock in stocks:
        ticker = stock.get('ticker', 'N/A')
        name = stock.get('name', 'N/A')
        price = stock.get('current_price', 0)
        change = format_percentage(stock.get('change_percent', 0))
        recommendation = stock.get('recommendation', '持有')
        analysis = stock.get('analysis', 'N/A').replace('\n', '<br>')

        emoji = "🟢" if stock.get('change_percent', 0) > 0 else "🔴" if stock.get('change_percent', 0) < 0 else "🟡"

        md += f"| **{ticker}**<br>{name} | ${price:.2f} | {emoji} {change} | 💎 **{recommendation}** | {analysis} |\n"

    md += "\n"
    return md


def generate_investment_strategy(data):
    """生成投資策略建議"""
    strategy = data.get('investment_strategy', {})

    md = """## 💼 投資策略建議

### 5.1 短期策略 (1-2週) ⏰

"""

    short_term = strategy.get('short_term', {})
    md += f"**市場觀點**: {short_term.get('market_view', 'N/A')}\n\n"

    md += "**操作重點**:\n"
    for i, focus in enumerate(short_term.get('key_focuses', []), 1):
        md += f"{i}. {focus}\n"

    md += "\n**具體行動** 📋\n\n"

    actions = short_term.get('actions', {})

    if actions.get('buy'):
        md += "✅ **買入操作**:\n"
        for item in actions.get('buy', []):
            ticker = item.get('ticker', 'N/A')
            reason = item.get('reason', 'N/A')
            entry = item.get('entry_price', 0)
            allocation = item.get('target_allocation_percent', 0)
            md += f"- **{ticker}**: {reason} (目標價: ${entry:.2f}, 配置: {allocation}%)\n"

    if actions.get('sell'):
        md += "\n⚠️ **賣出操作**:\n"
        for item in actions.get('sell', []):
            ticker = item.get('ticker', 'N/A')
            reason = item.get('reason', 'N/A')
            exit_price = item.get('exit_price', 0)
            md += f"- **{ticker}**: {reason} (目標價: ${exit_price:.2f})\n"

    if actions.get('hold'):
        md += "\n💎 **持有觀察**:\n"
        for item in actions.get('hold', []):
            ticker = item.get('ticker', 'N/A')
            monitoring = item.get('monitoring_point', 'N/A')
            support = item.get('support_level', 0)
            md += f"- **{ticker}**: {monitoring} (支撐位: ${support:.2f})\n"

    # 倉位建議
    allocation = short_term.get('allocation', {})
    md += f"\n📊 **倉位建議**:\n"
    md += f"- 股票: {allocation.get('stocks_percent', 0)}%\n"
    md += f"- 債券: {allocation.get('bonds_percent', 0)}%\n"
    md += f"- 黃金: {allocation.get('gold_percent', 0)}%\n"
    md += f"- 現金: {allocation.get('cash_percent', 0)}%\n"

    md += "\n---\n\n"

    return md


def yaml_to_markdown(yaml_file, output_file=None):
    """將 YAML 檔案轉換為 Markdown"""

    # 讀取 YAML
    with open(yaml_file, 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f)

    # 生成 Markdown
    markdown = ""
    markdown += generate_markdown_header(data)
    markdown += generate_executive_summary(data)
    markdown += generate_global_markets(data)
    markdown += generate_portfolio_analysis(data)
    markdown += generate_investment_strategy(data)

    # 添加免責聲明
    disclaimer = data.get('disclaimer', {})
    markdown += f"""## ⚠️ 免責聲明

{disclaimer.get('text', '')}

**投資風險提示**:
"""
    for warning in disclaimer.get('risk_warnings', []):
        markdown += f"- {warning}\n"

    markdown += "\n**建議**:\n"
    for rec in disclaimer.get('recommendations', []):
        markdown += f"- {rec}\n"

    markdown += "\n---\n\n**報告結束**\n"

    # 輸出
    if output_file:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(markdown)
        print(f"✅ Markdown 報告已保存至: {output_file}")
    else:
        print(markdown)

    return markdown


def main():
    """主函數"""
    if len(sys.argv) < 2:
        print("用法: python yaml_to_markdown.py <yaml_file> [output_file]")
        print("")
        print("範例:")
        print("  python yaml_to_markdown.py analysis/market/2025-12-01.yaml")
        print("  python yaml_to_markdown.py analysis/market/2025-12-01.yaml analysis/market/2025-12-01.md")
        sys.exit(1)

    yaml_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    if not Path(yaml_file).exists():
        print(f"❌ 錯誤: 找不到檔案 {yaml_file}")
        sys.exit(1)

    try:
        yaml_to_markdown(yaml_file, output_file)
    except Exception as e:
        print(f"❌ 錯誤: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
