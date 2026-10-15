#!/usr/bin/env bash
set -euo pipefail

# Instala el toolchain que falte. Ejecutar solo cuando se necesite.
# Uso: bash setup/install.sh [nuclei|ffuf|subfinder|httpx|dnsx|sqlmap|loxs|all]

echo "[*] Bounty Skills — Toolchain Installer"

install_go_tools() {
  command -v go >/dev/null || { echo "[-] Go no instalado — instala desde https://go.dev/dl/"; return 1; }
  echo "[*] Instalando toolchain ProjectDiscovery + ffuf..."
  go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
  go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
  go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
  go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
  go install -v github.com/ffuf/ffuf/v2@latest
  go install -v github.com/epi052/feroxbuster@latest 2>/dev/null || true
  echo "[*] Actualizando templates de nuclei..."
  nuclei -update-templates 2>/dev/null || true
  echo "[+] Go tools instaladas en $(go env GOPATH)/bin"
}

install_sqlmap() {
  command -v sqlmap >/dev/null && { echo "[+] sqlmap ya instalado"; return; }
  echo "[*] Instalando sqlmap..."
  sudo apt-get update -qq && sudo apt-get install -y -qq sqlmap 2>/dev/null \
    || { git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /tmp/sqlmap \
         && sudo ln -sf /tmp/sqlmap/sqlmap.py /usr/local/bin/sqlmap; }
}

install_loxs_deps() {
  echo "[*] Instalando deps de loxs..."
  ROOT="$(cd "$(dirname "$0")/.." && pwd)"
  pip install -r "$ROOT/tools/loxs/requirements.txt"
  echo "[*] selenium necesita Chrome/Chromium: sudo apt install chromium-browser"
}

install_seclists() {
  command -v feroxbuster >/dev/null || install_go_tools
  echo "[*] SecLists (wordlists extra)..."
  sudo apt-get install -y -qq seclists 2>/dev/null \
    || git clone --depth 1 https://github.com/danielmiessler/SecLists.git /usr/share/seclists
}

case "${1:-all}" in
  nuclei) install_go_tools ;;
  ffuf|subfinder|httpx|dnsx) install_go_tools ;;
  sqlmap) install_sqlmap ;;
  loxs) install_loxs_deps ;;
  seclists) install_seclists ;;
  all)
    install_go_tools
    install_sqlmap
    install_loxs_deps
    install_seclists
    ;;
  *) echo "Uso: $0 [nuclei|ffuf|subfinder|httpx|dnsx|sqlmap|loxs|seclists|all]"; exit 1 ;;
esac

echo "[+] Done. Verifica con: bash setup/inventory.sh"
