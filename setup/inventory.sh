#!/usr/bin/env bash
set -euo pipefail

# Inventory de tools de hacking — actualiza skill-registry.json con el estado real.
# Uso: bash setup/inventory.sh

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REGISTRY="$ROOT/skill-registry.json"

echo "[*] Bounty Skills — Tool Inventory"
echo "=================================="

TOOLS=(nmap curl jq python3 go docker nuclei ffuf subfinder httpx dnsx sqlmap feroxbuster subjack masscan nikto gobuster wfuzz ffuf rustscan netexec crackmapexec hydra john hashcat trufflehog gitleaks burpsuite)
STATUS_JSON="{"
FIRST=1

for t in "${TOOLS[@]}"; do
  if command -v "$t" >/dev/null 2>&1; then
    path=$(command -v "$t")
    printf "  \033[32m[+]\033[0m %-15s %s\n" "$t" "$path"
    st="installed"
  else
    printf "  \033[31m[-]\033[0m %-15s %s\n" "$t" "MISSING"
    st="missing"
  fi
  [ $FIRST -eq 1 ] && FIRST=0 || STATUS_JSON+=","
  STATUS_JSON+="\"$t\":\"$st\""
done
STATUS_JSON+="}"

echo
echo "[*] Estado:"
echo "$STATUS_JSON" | python3 -m json.tool 2>/dev/null || echo "$STATUS_JSON"

# Tools bundled del repo
echo
echo "[*] Bundled tools:"
for d in loxs scripts swagger pdf-exploits api-key-hunter crtmon; do
  if [ -e "$ROOT/tools/$d" ]; then echo "  [+] tools/$d OK"; else echo "  [-] tools/$d missing"; fi
done
echo "  [+] wordlists: $(ls "$ROOT/wordlists" | wc -l) files"

# Loxs deps
python3 -c "import selenium, aiohttp, bs4" 2>/dev/null \
  && echo "  [+] loxs deps (selenium/aiohttp/bs4) OK" \
  || echo "  [-] loxs deps missing → pip install -r tools/loxs/requirements.txt"

echo
echo "Registry: $REGISTRY"
echo "Para instalar lo que falta: bash setup/install.sh"
