#!/bin/bash
VAULT_PATH="$(pwd)"
echo "🔍 Scanning Vault: $VAULT_PATH"
broken_links=0
while IFS= read -r file; do
    grep -oP '\[\[\K[^\]]+' "$file" 2>/dev/null | while read -r link; do
        clean_link="${link%%#*}"
        if [[ ! -f "${clean_link}.md" && ! -f "${clean_link}" ]]; then
            echo -e "\e[31m✗\e[0m Broken link in $file: [[${link}]]"
            ((broken_links++))
        fi
    done
done < <(find . -name "*.md" -not -path "./_*" -not -path "./.*")
if [ $broken_links -eq 0 ]; then echo -e "\e[32m✓\e[0m All links valid"; else echo -e "\e[31m✗ Found $broken_links broken link(s)\e[0m"; fi
