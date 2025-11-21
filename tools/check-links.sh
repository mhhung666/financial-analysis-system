#!/bin/bash
# Markdown 連結檢查腳本
# 檢查所有 .md 檔案中的內部連結是否存在

# 不使用 set -e，因為某些命令可能返回非零退出碼（如 grep 找不到匹配）

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 專案根目錄
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "========================================"
echo "Markdown 連結檢查工具"
echo "========================================"
echo "專案目錄: $PROJECT_ROOT"
echo ""

# 暫存檔案
ERRORS_FILE=$(mktemp)
STATS_FILE=$(mktemp)
trap "rm -f $ERRORS_FILE $STATS_FILE" EXIT

echo "0" > "$STATS_FILE"  # 初始化連結計數

# 檢查單個 Markdown 檔案中的連結
check_file() {
    local file="$1"
    local file_dir="$(dirname "$file")"
    local relative_file="${file#$PROJECT_ROOT/}"

    # 提取所有 Markdown 連結 [text](path)
    local matches
    matches=$(grep -oP '\[[^\]]*\]\([^)]+\)' "$file" 2>/dev/null || true)

    if [[ -z "$matches" ]]; then
        return
    fi

    echo "$matches" | while read -r match; do
        # 提取括號內的路徑
        link_path=$(echo "$match" | sed -n 's/.*](\([^)]*\)).*/\1/p')

        # 跳過外部連結和錨點連結
        if [[ "$link_path" =~ ^https?:// ]] || \
           [[ "$link_path" =~ ^mailto: ]] || \
           [[ "$link_path" =~ ^# ]]; then
            continue
        fi

        # 移除錨點部分 (如 file.md#section)
        link_path="${link_path%%#*}"

        # 空路徑則跳過
        if [[ -z "$link_path" ]]; then
            continue
        fi

        # 計數
        count=$(cat "$STATS_FILE")
        echo $((count + 1)) > "$STATS_FILE"

        # 解析實際路徑
        if [[ "$link_path" =~ ^\./ ]]; then
            # 相對路徑 ./file.md
            actual_path="$file_dir/${link_path#./}"
        elif [[ "$link_path" =~ ^\.\. ]]; then
            # 上層目錄 ../path/file.md
            actual_path="$file_dir/$link_path"
        elif [[ "$link_path" =~ ^/ ]]; then
            # 絕對路徑 (從專案根目錄)
            actual_path="$PROJECT_ROOT$link_path"
        else
            # 其他相對路徑 (可能是從檔案所在目錄或專案根目錄)
            # 先嘗試從檔案所在目錄
            if [[ -e "$file_dir/$link_path" ]]; then
                actual_path="$file_dir/$link_path"
            else
                # 再嘗試從專案根目錄
                actual_path="$PROJECT_ROOT/$link_path"
            fi
        fi

        # 正規化路徑
        actual_path=$(realpath -m "$actual_path" 2>/dev/null || echo "$actual_path")

        # 檢查檔案或目錄是否存在
        if [[ ! -e "$actual_path" ]]; then
            echo "$relative_file|$link_path" >> "$ERRORS_FILE"
        fi
    done
}

# 找到所有 Markdown 檔案並檢查
echo "開始掃描 Markdown 檔案..."
echo ""

checked_files=0
while IFS= read -r -d '' file; do
    check_file "$file"
    ((checked_files++))
done < <(find "$PROJECT_ROOT" -name "*.md" -type f -print0 | sort -z)

# 讀取統計
total_links=$(cat "$STATS_FILE")
broken_links=0

# 顯示錯誤
if [[ -s "$ERRORS_FILE" ]]; then
    while IFS='|' read -r file link; do
        ((broken_links++))
        echo -e "${RED}❌ 找不到連結${NC}"
        echo "   檔案: $file"
        echo "   連結: $link"
        echo ""
    done < "$ERRORS_FILE"
fi

# 輸出摘要
echo "========================================"
echo "檢查完成"
echo "========================================"
echo -e "檢查檔案數: ${GREEN}$checked_files${NC}"
echo -e "總連結數: ${GREEN}$total_links${NC}"

if [[ $broken_links -eq 0 ]]; then
    echo -e "失效連結: ${GREEN}0${NC}"
    echo ""
    echo -e "${GREEN}✅ 所有連結都有效！${NC}"
    exit 0
else
    echo -e "失效連結: ${RED}$broken_links${NC}"
    echo ""
    echo -e "${RED}⚠️  發現 $broken_links 個失效連結${NC}"
    exit 1
fi
