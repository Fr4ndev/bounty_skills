---
name: loxs-scanner
description: "Multi-vulnerability scanner web: LFI, Open Redirect, XSS, SQLi y CRLF en un solo pass multi-threaded. Incluye payloads propios por DBMS."
version: 1.0.0
author: Fr4ndev
license: MIT
platforms: [linux, macos]
metadata:
  tags: [attack, scanner, xss, sqli, lfi, crlf, open-redirect, automated]
  tools: [loxs.py, python3, selenium, aiohttp]
  required: [python3]
  related_skills: [sqli-hunting, xss-hunting, lfi-rfi, ssrf-crlf]
  stage: attack
---

# Loxs — LFI · OR · XSS · SQLi · CRLF

Scanner multi-vulnerabilidad con detección por success-criteria y generación de reporte HTML.

## Setup (una vez)

```bash
cd tools/loxs
pip install -r requirements.txt
# selenium requiere Chrome/Chromium instalado
```

## Uso

```bash
# lista de URLs con parámetros (salida de wayback-dorking o params.txt fuzz)
python3 tools/loxs/loxs.py -u "https://target.com/page?id=1" -t all

# escanear un file de URLs
python3 tools/loxs/loxs.py -l urls_params.txt -t xss,sqli,lfi,or,crlf

# guardar vulnerables + HTML report
python3 tools/loxs/loxs.py -l urls_params.txt -t all -o recon/loxs_report.html
```

## Generar input de calidad (parámetros reales)

```bash
# Extraer URLs con params del harvest
grep -E "\?.*=" recon/target.com/wayback_urls.txt | sort -u > urls_params.txt

# O fuzzear params con wordlist bundled
ffuf -u "https://target.com/FUZZ" -w wordlists/params.txt -mc all -fc 404 -o fuzz_params.json
```

## Interpretación y escalada

| Hallazgo | Siguiente paso manual |
|---|---|
| SQLi detectado | skill `sqli-hunting` — confirmar DBMS con payloads de `tools/loxs/payloads/sqli/` |
| XSS detectado | skill `xss-hunting` — confirmar sink (reflected/stored/DOM) |
| LFI detectado | skill `lfi-rfi` — escalar a RCE vía wrappers y log poisoning |
| Open Redirect | encadenar con OAuth/SSO flows para account takeover |
| CRLF | header injection → XSS vía `Location` o cache poisoning |

## Customización

- Payloads en `tools/loxs/payloads/` (mysql, postgresql, mssql, oracle, xor, xss, lfi, or, crlf).
- Success criteria editables en `loxs.py` — afínalo contra WAFs concretos.
