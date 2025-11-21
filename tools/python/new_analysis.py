#!/usr/bin/env python3
"""
季度報告產製自動化腳本

功能:
1. 從模板複製檔案到新的分析資料夾
2. 在 analysis/YYYYQN/[TICKER]/ 建立新資料夾
3. 替換模板中的佔位符 (股票代碼、公司名稱、季度等)
4. 自動更新 INDEX.md 新增條目

使用方式:
    python new_analysis.py TICKER "公司名稱" --quarter 2025Q4
    python new_analysis.py AAPL "Apple Inc." --quarter 2025Q4 --industry "科技"
"""

import argparse
import os
import shutil
import sys
from datetime import datetime
from pathlib import Path

# 專案根目錄
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
TEMPLATE_DIR = PROJECT_ROOT / "templates" / "analysis" / "full-earnings-analysis-template"
ANALYSIS_DIR = PROJECT_ROOT / "analysis"
INDEX_FILE = PROJECT_ROOT / "INDEX.md"


def get_current_quarter() -> str:
    """取得當前季度 (格式: YYYYQN)"""
    now = datetime.now()
    quarter = (now.month - 1) // 3 + 1
    return f"{now.year}Q{quarter}"


def create_analysis_folder(ticker: str, quarter: str) -> Path:
    """建立分析資料夾"""
    target_dir = ANALYSIS_DIR / quarter / ticker

    if target_dir.exists():
        print(f"警告: 資料夾已存在 {target_dir}")
        response = input("是否要覆蓋? (y/N): ")
        if response.lower() != 'y':
            print("已取消操作")
            sys.exit(0)
        shutil.rmtree(target_dir)

    # 確保季度資料夾存在
    quarter_dir = ANALYSIS_DIR / quarter
    quarter_dir.mkdir(parents=True, exist_ok=True)

    # 複製模板
    if not TEMPLATE_DIR.exists():
        print(f"錯誤: 找不到模板資料夾 {TEMPLATE_DIR}")
        sys.exit(1)

    shutil.copytree(TEMPLATE_DIR, target_dir)
    print(f"✅ 已建立資料夾: {target_dir}")

    return target_dir


def replace_placeholders(target_dir: Path, ticker: str, company_name: str,
                         quarter: str, industry: str):
    """替換模板檔案中的佔位符"""
    # 解析季度資訊
    year = quarter[:4]
    q_num = quarter[-1]  # 取得季度數字 (1-4)

    placeholders = {
        # 雙大括號格式
        "{{TICKER}}": ticker,
        "{{COMPANY_NAME}}": company_name,
        "{{QUARTER}}": quarter,
        "{{INDUSTRY}}": industry,
        "{{DATE}}": datetime.now().strftime("%Y-%m-%d"),
        "{{YEAR}}": year,
        "{{Q}}": f"Q{q_num}",
        # 中括號格式 (模板使用的格式)
        "[TICKER]": ticker,
        "[COMPANY_NAME]": company_name,
        "[QUARTER]": quarter,
        "[INDUSTRY]": industry,
        "[Quarter]": q_num,
        "[Year]": year,
        "[YYYY-MM-DD]": datetime.now().strftime("%Y-%m-%d"),
        "[Date]": datetime.now().strftime("%Y-%m-%d"),
        "[Name]": "Claude",
    }

    # 處理所有 markdown 檔案
    for md_file in target_dir.glob("*.md"):
        content = md_file.read_text(encoding='utf-8')

        for placeholder, value in placeholders.items():
            content = content.replace(placeholder, value)

        md_file.write_text(content, encoding='utf-8')
        print(f"  📝 已更新: {md_file.name}")


def update_index(ticker: str, company_name: str, quarter: str, industry: str):
    """更新 INDEX.md 新增條目"""
    if not INDEX_FILE.exists():
        print(f"警告: 找不到 INDEX.md ({INDEX_FILE})")
        return

    content = INDEX_FILE.read_text(encoding='utf-8')

    # 找到季度區塊的位置並插入新條目
    quarter_marker = f"### {quarter}"
    analysis_link = f"analysis/{quarter}/{ticker}/"

    # 檢查是否已存在
    if analysis_link in content:
        print(f"ℹ️  INDEX.md 已包含 {ticker} 的 {quarter} 條目")
        return

    # 準備新條目
    new_entry = f"- [ ] [{ticker} - {company_name}]({analysis_link}) | 待分析 | {industry}\n"

    # 找到對應季度區塊
    if quarter_marker in content:
        # 在季度標題後插入
        lines = content.split('\n')
        new_lines = []
        found_quarter = False
        inserted = False

        for i, line in enumerate(lines):
            new_lines.append(line)

            if quarter_marker in line:
                found_quarter = True
                continue

            # 在季度區塊的第一個列表項後插入
            if found_quarter and not inserted:
                # 跳過可能的描述行 (> 開頭)
                if line.startswith('>'):
                    continue
                # 跳過空行
                if line.strip() == '':
                    continue
                # 在列表項之前插入
                if line.strip().startswith('- '):
                    new_lines.insert(-1, new_entry.rstrip())
                    inserted = True
                    found_quarter = False

        if not inserted:
            # 如果季度區塊為空，在 marker 後新增
            idx = content.find(quarter_marker)
            end_of_line = content.find('\n', idx)
            # 找到描述行結束的位置
            next_section = content.find('\n\n', end_of_line)
            if next_section == -1:
                next_section = len(content)

            content = (content[:next_section] + '\n' + new_entry +
                      content[next_section:])
            INDEX_FILE.write_text(content, encoding='utf-8')
        else:
            content = '\n'.join(new_lines)
            INDEX_FILE.write_text(content, encoding='utf-8')

        print(f"✅ 已更新 INDEX.md: 新增 {ticker} 至 {quarter} 區塊")
    else:
        # 季度區塊不存在，需要新建
        print(f"⚠️  INDEX.md 中找不到 {quarter} 區塊")
        print(f"   請手動新增以下內容到「按季度查看」區塊:")
        print(f"\n{quarter_marker}")
        print(f"> 財報發布：待定\n")
        print(new_entry)


def main():
    parser = argparse.ArgumentParser(
        description="季度報告產製自動化腳本",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
範例:
    %(prog)s AAPL "Apple Inc." --quarter 2025Q4
    %(prog)s MSFT "Microsoft Corporation" --quarter 2025Q4 --industry "雲端運算"
    %(prog)s NVDA "NVIDIA Corporation"  # 使用當前季度
        """
    )

    parser.add_argument(
        "ticker",
        help="股票代碼 (例: AAPL, MSFT)"
    )
    parser.add_argument(
        "company_name",
        help="公司名稱 (例: Apple Inc.)"
    )
    parser.add_argument(
        "--quarter", "-q",
        default=get_current_quarter(),
        help=f"季度 (格式: YYYYQN, 預設: {get_current_quarter()})"
    )
    parser.add_argument(
        "--industry", "-i",
        default="待分類",
        help="產業類別 (預設: 待分類)"
    )
    parser.add_argument(
        "--no-index",
        action="store_true",
        help="不更新 INDEX.md"
    )

    args = parser.parse_args()

    # 轉換為大寫
    ticker = args.ticker.upper()

    print(f"\n📊 建立新分析報告")
    print(f"   股票代碼: {ticker}")
    print(f"   公司名稱: {args.company_name}")
    print(f"   季度: {args.quarter}")
    print(f"   產業: {args.industry}")
    print()

    # 1. 建立資料夾並複製模板
    target_dir = create_analysis_folder(ticker, args.quarter)

    # 2. 替換佔位符
    print("\n📝 更新模板內容...")
    replace_placeholders(
        target_dir,
        ticker,
        args.company_name,
        args.quarter,
        args.industry
    )

    # 3. 更新 INDEX.md
    if not args.no_index:
        print("\n📑 更新 INDEX.md...")
        update_index(ticker, args.company_name, args.quarter, args.industry)

    print(f"\n✨ 完成! 請編輯以下檔案開始分析:")
    print(f"   {target_dir}/")
    for md_file in sorted(target_dir.glob("*.md")):
        print(f"     - {md_file.name}")


if __name__ == "__main__":
    main()
