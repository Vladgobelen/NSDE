#!/bin/bash
# dump.sh — собирает все исходники проекта NSDE в один файл.
# Использование: ./dump.sh [output.txt]
# По умолчанию пишет в nsde_dump.txt.

OUT="${1:-nsde_dump.txt}"
ROOT="$(cd "$(dirname "$0")" && pwd)"

# Что включаем (по расширению).
EXTENSIONS=("rs" "lua" "toml" "sh" "md" "txt")

# Что исключаем (по пути).
EXCLUDES=(
    "target"
    ".git"
    "Cargo.lock"
    "nsde_dump.txt"
    "dump.sh"
    ".idea"
    ".vscode"
)

echo "=== NSDE project dump ===" > "$OUT"
echo "=== Generated: $(date) ===" >> "$OUT"
echo "=== Root: $ROOT ===" >> "$OUT"
echo "" >> "$OUT"

# Функция проверки исключений
should_exclude() {
    local path="$1"
    for ex in "${EXCLUDES[@]}"; do
        if [[ "$path" == *"/$ex"* ]] || [[ "$path" == *"/$ex" ]]; then
            return 0
        fi
    done
    return 1
}

# Функция проверки расширения
should_include() {
    local path="$1"
    for ext in "${EXTENSIONS[@]}"; do
        if [[ "$path" == *".$ext" ]]; then
            return 0
        fi
    done
    return 1
}

# Обход всех проектов
for project in nspanel nsbridge nswm ns-widgets ns-widgets-lua; do
    proj_path="$ROOT/$project"
    if [[ ! -d "$proj_path" ]]; then
        echo "--- skip: $project (not found) ---" >> "$OUT"
        continue
    fi

    echo "" >> "$OUT"
    echo "############################################################" >> "$OUT"
    echo "### PROJECT: $project" >> "$OUT"
    echo "############################################################" >> "$OUT"
    echo "" >> "$OUT"

    # Находим все файлы нужных расширений, сортируем
    find "$proj_path" -type f \( -name "*.rs" -o -name "*.lua" -o -name "*.toml" -o -name "*.sh" -o -name "*.md" -o -name "*.txt" \) | sort | while read -r file; do
        if should_exclude "$file"; then
            continue
        fi
        if ! should_include "$file"; then
            continue
        fi

        rel="${file#$ROOT/}"
        echo "=== FILE: $rel ===" >> "$OUT"
        echo '```' >> "$OUT"
        cat "$file" >> "$OUT"
        echo '```' >> "$OUT"
        echo "" >> "$OUT"
    done
done

echo "=== Done. Written to $OUT ==="
echo "=== Size: $(du -h "$OUT" | cut -f1) ==="