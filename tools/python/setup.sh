#!/bin/bash
# Python 環境快速設定腳本

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VENV_DIR="$SCRIPT_DIR/venv"

echo "================================"
echo "Python 環境設定腳本"
echo "================================"
echo ""

# 檢查 Python 是否安裝
if ! command -v python3 &> /dev/null; then
    echo "錯誤: 找不到 python3，請先安裝 Python 3"
    exit 1
fi

echo "Python 版本: $(python3 --version)"
echo ""

# 檢查虛擬環境是否已存在
if [ -d "$VENV_DIR" ]; then
    echo "虛擬環境已存在: $VENV_DIR"
    read -p "是否要刪除並重新建立? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "刪除現有虛擬環境..."
        rm -rf "$VENV_DIR"
    else
        echo "保留現有虛擬環境"
        echo ""
        echo "如要啟動虛擬環境，請執行:"
        echo "  source $VENV_DIR/bin/activate"
        exit 0
    fi
fi

# 建立虛擬環境
echo "建立虛擬環境: $VENV_DIR"
python3 -m venv "$VENV_DIR"

# 啟動虛擬環境
echo "啟動虛擬環境..."
source "$VENV_DIR/bin/activate"

# 升級 pip
echo "升級 pip..."
pip install --upgrade pip

# 安裝依賴套件
echo "安裝依賴套件..."
pip install -r "$SCRIPT_DIR/requirements.txt"

echo ""
echo "================================"
echo "設定完成!"
echo "================================"
echo ""
echo "虛擬環境位置: $VENV_DIR"
echo ""
echo "使用方式:"
echo "  1. 啟動虛擬環境:"
echo "     source $VENV_DIR/bin/activate"
echo ""
echo "  2. 執行工具，例如:"
echo "     python3 tools/python/scrapers/fetch_market_data.py JPY=X -o data/market-data/2025/Stocks/USDJPY.md"
echo ""
echo "  3. 使用完畢後停用虛擬環境:"
echo "     deactivate"
echo ""
