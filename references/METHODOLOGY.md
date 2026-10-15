# Metodología de ataque — Bounty Kill Chain

Flujo que el agente debe seguir cuando se le da un target sin instrucciones específicas.

## 0. Reglas de engagement (SIEMPRE primero)

1. Scope del programa: dominios permitidos, tipos de vuln, exclusiones.
2. Rate limiting propio: no más de ~10 req/s contra producción.
3. No acceder a datos de usuarios reales. Usa cuentas propias.
4. No destructivo. No DoS. No denegación de servicios.

## 1. Recon pasivo (sin tocar el target)

```
skill: wayback-dorking      → URLs históricas, secrets en params, archivos olvidados
skill: subdomain-enum fase 1 → crt.sh, OTX, wayback domains
skill: api-key-hunter        → keys filtradas en dorks/GitHub
skill: osint-spiderfoot      → emails, leaks, tech, empleados
```

## 2. Recon activo

```
skill: subdomain-enum fases 3-4 → resolve + probe → live.txt con tech
skill: certstream-crtmon        → monitoreo continuo
nmap -sV -T4 <hosts> (si scope permite)
```

## 3. Selección de ataque por tech detectada

| Tech / superficie | Skill de ataque |
|---|---|
| Cualquier web con params | `loxs-scanner` (pass general) |
| API / GraphQL / Swagger | `api-swagger-fuzz` |
| PHP | `lfi-rfi` (wrappers, log poisoning) |
| Forms / search | `xss-hunting` |
| Redirects / webhooks / url params | `ssrf-crlf` |
| Admin paths / auth walls | `403-bypass` |
| Generadores de PDF | `pdf-exploits` |
| WordPress | wordlists `coffin-wp-fuzz.txt`, `wordpress-random.txt` |

## 4. Escalada

- LFI → RCE (wrappers / log poisoning / upload)
- XSS → session hijack (cookies sin httpOnly) → account takeover
- Open redirect → OAuth/SSO chain → ATO
- SSRF → cloud metadata → credentials → takeover infra
- 403 bypass → IDOR/BAC → PII de otros usuarios

## 5. Reporte

```
skill: bug-bounty-report
```

Checklist: PoC reproducible <2min, impacto business, sin datos reales, video si >4 pasos.

## Loop de mejora

- Tras cada engagement: ¿qué skill falló? ¿Qué tool faltaba? → actualizar SKILL.md + registry.
- Nuevos hallazgos → plantillas nuevas en `references/`.
