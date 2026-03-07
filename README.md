# OpenClaw Lightsail Setup

One-command setup for new OpenClaw instances on AWS Lightsail.

## Quick Start

SSH into your Lightsail instance and run:

```bash
curl -sSL https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/lightsail-setup.sh | bash
```

Or download and run manually:

```bash
wget https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/lightsail-setup.sh
chmod +x lightsail-setup.sh
./lightsail-setup.sh
```

## What It Installs

| Tool | Purpose |
|------|---------|
| OpenClaw (latest) | AI assistant framework |
| gog CLI | Google Workspace (Gmail, Calendar, Drive, Docs) |
| Vercel CLI | Web app deployment |
| Supabase CLI | Database management |
| GitHub CLI (gh) | GitHub operations |
| Claude Code | AI coding agent |
| Salesforce CLI | CRM integration |
| Python 3 + pip | Custom scripts |
| Utilities | jq, tmux, htop, tree |

## Prerequisites

- AWS Lightsail instance (Ubuntu, 2GB+ RAM)
- OpenClaw blueprint selected, OR Node.js 20+ installed
- User with sudo access (default `ubuntu` user works)

## After Setup

1. `openclaw status` — verify it's running
2. `openclaw auth add anthropic` — add your API key
3. Edit `~/.openclaw/openclaw.json` — configure channels
4. `openclaw whatsapp link` — connect WhatsApp
5. Edit `~/.openclaw/workspace/SOUL.md` — give it personality

## Support

- Docs: https://docs.openclaw.ai
- Discord: https://discord.com/invite/clawd
