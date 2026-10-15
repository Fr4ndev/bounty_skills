# bounty_skills

**Skill registry brutal para pentesting, hacking y bug bounty.** Diseñado para que un agente de IA (opencode, Hermes, Claude Code, etc.) consulte el registry, elija el skill según el target y ejecute pipelines completos de reconocimiento → ataque → exploit → reporte.

> ⚠️ **Disclaimer**: Solo para uso educativo y en entornos con autorización explícita (programas bug bounty, laboratorios propios, pentests contratados). El autor no se hace responsable del uso indebido.

## Estructura

```
bounty_skills/
├── skill-registry.json      # REGISTRO MAESTRO — el agente empieza aquí
├── setup/
│   ├── inventory.sh         # audita qué tools hay instaladas
│   └── install.sh           # instala el toolchain que falte (nuclei, ffuf, sqlmap...)
├── skills/
│   ├── recon/               # subdomain-enum · osint-spiderfoot · wayback-dorking · api-key-hunter · certstream-crtmon
│   ├── attack/              # loxs-scanner · sqli-hunting · xss-hunting · lfi-rfi · ssrf-crlf · 403-bypass · api-swagger-fuzz
│   ├── exploits/            # pdf-exploits (CVE-2024-4367 PDF.js)
│   ├── redteam/             # llm-jailbreak-godmode (GODMODE, Parseltongue, ULTRAPLINIAN)
│   └── report/              # bug-bounty-report
├── tools/
│   ├── loxs/                # LFI·OR·XSS·SQLi·CRLF multi-threaded scanner
│   ├── scripts/             # wayback, alienvault, virustotal, urlscan, dorking, naabu→map, punycode, CORS PoC, lostfuzzer
│   ├── swagger/             # API wordlist + login/XSS JSON PoCs
│   ├── pdf-exploits/        # PoCs PDF.js
│   ├── api-key-hunter/      # Gemisc.py + keyhunt.py
│   └── crtmon/              # certstream monitor (Go)
├── wordlists/               # 64 wordlists: sqli, xss, lfi, ssrf, ssti, crlf, 403, jwt, params, api...
└── references/              # playbooks de metodología
```

## Cómo lo usa el agente

1. **Lee `skill-registry.json`** → sabe qué skills existen, sus triggers, tools y stage.
2. **`bash setup/inventory.sh`** → detecta qué hay instalado y qué falta.
3. **Target asignado** → el agente mapea objetivo → stage → skill:
   - *"Dame el surface de example.com"* → `recon/subdomain-enum`
   - *"Ataca esta URL con params"* → `attack/loxs-scanner` → escala según hallazgos
   - *"Escribe el reporte"* → `report/bug-bounty-report`
4. **Cada skill es autónomo**: SKILL.md con comandos copy-pasteable, wordlists bundled, y referencias a skills de escalada.

## Pipeline por defecto (modo autonomous)

```bash
# 0. Inventario
bash setup/inventory.sh

# 1. Recon
# → skills/recon/subdomain-enum  → live.txt
# → skills/recon/wayback-dorking → urls_params.txt + high_value.txt
# → skills/recon/osint-spiderfoot

# 2. Attack (sobre live.txt / urls_params.txt)
# → skills/attack/loxs-scanner (pass general)
# → skills/attack/* según tipo de target

# 3. Escalada
# → skills/exploits/pdf-exploits si el target genera PDFs

# 4. Reporte
# → skills/report/bug-bounty-report
```

## Instalación de toolchain (opcional, on-demand)

Las skills funcionan con lo bundled (curl, python3). Para potencia total:

```bash
bash setup/install.sh all      # nuclei + templates, subfinder, httpx, dnsx, ffuf, sqlmap, seclists
bash setup/inventory.sh        # verificar
```

## Bundled highlights

- **`tools/loxs/`** — scanner LFI·OR·XSS·SQLi·CRLF multi-thread con payloads por DBMS y reporte HTML.
- **`wordlists/`** — 64 lists (~75MB): `everything.txt`, `api.txt`, `allsqli.txt`, `xss.txt`, `lfi.txt`, `ssrf.txt`, `ssti.txt`, `jwt-secrets.txt`, `github-dork.txt`...
- **`tools/scripts/`** — OSINT automatizado (Wayback, OTX, VirusTotal, urlscan) + dorking + CORS PoC.
- **`tools/pdf-exploits/`** — CVE-2024-4367 PDF.js arbitrary JS execution.
- **`skills/redteam/llm-jailbreak-godmode/`** — GODMODE, Parseltongue (33 técnicas de ofuscación), ULTRAPLINIAN (race multi-modelo).

## Integración con opencode

```bash
git clone https://github.com/Fr4ndev/bounty_skills.git ~/.config/opencode/skills/bounty
# o añadir como plugin/AGENTS.md pointing al registry
```

Cada `skills/*/SKILL.md` sigue el formato estándar de skills (frontmatter YAML + markdown), compatible con opencode, Claude Code y Hermes.

## Estructura de un skill

```markdown
---
name: xss-hunting
description: "..."
tools: [curl, loxs]
stage: attack
triggers: [xss, javascript]
---
# Contenido con comandos ejecutables
```

## Licencia

MIT. Los tools bundled mantienen sus licencias originales (ver LICENSE de cada uno en `tools/`). Disclaimers de uso autorizado en cada README de herramienta.
