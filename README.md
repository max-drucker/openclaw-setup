# OpenClaw Setup — AWS EC2

Automated setup for OpenClaw AI assistant instances on AWS EC2 (Ubuntu 24.04 LTS).

## Recommended Instance

- **Type:** `t3.medium` (4GB RAM, 2 vCPU)
- **OS:** Ubuntu 24.04 LTS
- **Storage:** 30GB gp3
- **Cost:** ~$30/mo + pay-per-use OpenRouter (~$5-20/mo)

## Two-Phase Install

### Phase 1: Install Tools (run as sudo)
```bash
curl -sSL https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/setup.sh | sudo bash
```

Or use EC2 User Data for automatic install on launch:
```bash
#!/bin/bash
curl -sSL https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/setup.sh | bash
```

Installs: OpenClaw, Node.js, gog, Supabase, GitHub CLI, Railway, Vercel, Claude Code, Codex, Salesforce CLI, AWS CLI, pandoc, Python, utilities.

### Phase 2: Configure Assistant (run as normal user)
```bash
curl -sSL https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/configure.sh | bash
```

Interactive setup that asks for:
- Person's name, email, phone, timezone, role
- Whether they're a Carpe Data employee (loads company knowledge + role-specific personality)
- OpenRouter API key
- WhatsApp linking

Creates: SOUL.md, USER.md, AGENTS.md, MEMORY.md, HEARTBEAT.md, openclaw.json, and (for Carpe employees) COMPANY.md + product/team/process knowledge files.

## EC2 Security Group

Open these ports:
- **22** (SSH)
- **18789** (OpenClaw Control UI)

## Post-Install Configuration

```bash
# Set gateway token
openclaw config set gateway.auth.token 'your-secure-token'

# Enable remote access
openclaw config set gateway.bind 'lan'
openclaw config set gateway.controlUi.allowedOrigins '["*"]'

# Set default model (via OpenRouter)
openclaw config set agents.defaults.model '{"primary":"openrouter/anthropic/claude-opus-4.6"}'
```

## Known Issues

- **`paste-token` strips OpenRouter key prefix:** The `sk-or-v1-` prefix gets stripped when writing to `auth-profiles.json`. Verify and fix manually after running `paste-token`.
- **`openclaw tui`** is the interactive test command (not `openclaw chat`)
- **Control UI** is on port **18789** (not 3000)

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
