# OpenClaw Setup — AWS Lightsail

Automated setup for OpenClaw AI assistant instances on AWS Lightsail.

## Two-Phase Install

### Phase 1: Install Tools (run as sudo)
```bash
curl -sSL https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/setup.sh | sudo bash
```

Installs: OpenClaw, Node.js, gog, Supabase, GitHub CLI, Railway, Vercel, Claude Code, Codex, Salesforce CLI, pandoc, Python, utilities.

### Phase 2: Configure Assistant (run as normal user)
```bash
curl -sSL https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/configure.sh | bash
```

Interactive setup that asks for:
- Person's name, email, phone, timezone, role
- Whether they're a Carpe Data employee (loads company knowledge + role-specific personality)
- Anthropic API key
- WhatsApp linking

Creates: SOUL.md, USER.md, AGENTS.md, MEMORY.md, HEARTBEAT.md, openclaw.json, and (for Carpe employees) COMPANY.md + product/team/process knowledge files.

## Templates

| File | Description |
|------|-------------|
| `templates/COMPANY.md` | Carpe Data company overview |
| `templates/memory/carpe-products.md` | Product deep dive (Minerva + ClaimsX) |
| `templates/memory/carpe-team.md` | Leadership, org chart, routing |
| `templates/memory/carpe-processes.md` | Sales process, tools, workflows |
| `templates/souls/carpe-sales.md` | Sales role personality |
| `templates/souls/carpe-engineering.md` | Engineering role personality |
| `templates/souls/carpe-executive.md` | Executive role personality |
| `templates/souls/carpe-ops.md` | Operations role personality |
| `templates/AGENTS.md` | Workspace conventions |
| `templates/HEARTBEAT.md` | Periodic check config |
| `templates/MEMORY.md` | Memory starter template |

## Docs

- [Friends & Family Guide](https://docs.google.com/document/d/1NnazvWkDrvt7v44m1KND81yhRePxnWD-14ap0MD-teQ) — End-user setup walkthrough
- [DevOps Guide](https://docs.google.com/document/d/11woADLWa0dKZ5xzs1W7ckhsabZEyxbqhKuRTutgUW1Y) — Provisioning runbook for Joe
