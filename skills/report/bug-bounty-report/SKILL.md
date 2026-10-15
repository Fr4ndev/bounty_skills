---
name: bug-bounty-report
description: "Redactar reportes de bounty que pagan: estructura, impacto business, PoC reproducible, CVSS y comunicación con triage."
version: 1.0.0
author: Fr4ndev
license: MIT
platforms: [linux, macos]
metadata:
  tags: [report, bug-bounty, triage, cvss, writeup]
  tools: []
  required: []
  related_skills: [loxs-scanner, sqli-hunting, xss-hunting, 403-bypass]
  stage: report
---

# Bug Bounty Report — Que Pague

Un hallazgo sin buen reporte = $0. Un hallazgo mediocre con impacto business demostrado = $500.

## Estructura del reporte

```markdown
# [Vuln Class] — [Component] — [Impact resumen en 1 línea]
**Severity:** Critical / High / Medium (CVSS vector)
**Endpoint:** https://target.com/endpoint (método)

## Summary
2-3 frases: qué, dónde, por qué importa al negocio.

## Steps to Reproduce
1. Ve a X (autenticado como usuario normal A)
2. Envía POST ... con body ...
3. Observa que ...
4. Cambia el header/ID a ... y observa respuesta de usuario B

## PoC
- request.http (Burp) / curl copy-pasteable
- Screenshots / video (Loom para stored XSS y flujos largos)

## Impact
Business terms: "cualquier usuario autenticado puede leer facturas de otros
clientes (PII + importes) → GDPR + pérdida de confianza"
NO: "se puede cambiar el parámetro id"

## Remediation (opcional pero suma)
"Autorización basada en propiedad del recurso en server-side, no solo en UI"
```

## Reglas de severidad (guía rápida)

| Hallazgo | Sev |
|---|---|
| RCE / SQLi con extracción / auth bypass admin | Critical |
| IDOR con PII / stored XSS en página principal / account takeover | High |
| Reflected XSS + interacción / CORS con data / SSRF sin metadata | Medium |
| Self-XSS / headers informativos / swagger sin datos | Low/Info |

## Que NO reportar (avoid list)

- Self-XSS sin chain · clickjacking en páginas sin acción sensible
- Missing rate limiting sin PoC de abuso · SSL/TLS versiones viejas
- Bugs en third-parties fuera de scope · "no existe cabena X" sin explotación
- Versiones de software sin vuln asociada · CSP report-only findings

## Comunicación con triage

- Responde en <48h, con datos, sin discutir severidad en tono agresivo.
- Si te bajan la severidad: pide los criterios del programa y contraargumenta con business impact.
- Never disclose antes de fix: respeta el coordinated disclosure.
- Duplicados: busca primero en la sección de reports resueltos del programa.

## Checklist pre-envío

- [ ] Scope verificado (host + tipo de vuln permitido)
- [ ] PoC reproducible en <2 minutos por el triage
- [ ] Impacto en términos de negocio, no técnicos
- [ ] Sin datos reales de usuarios en el PoC (usa tus cuentas)
- [ ] Sin credentials en los attachments
- [ ] Video si el flujo tiene >4 pasos
