#!/usr/bin/env bash
# ============================================================
# OpenClaw Configure Script — Phase 2
# Sets up the assistant's workspace, personality, and config
# Run AFTER setup.sh (which installs all tools)
#
# Usage (MUST download first — this script is interactive):
#   curl -Lo configure.sh https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/configure.sh && bash configure.sh
#
# ⚠️  Do NOT pipe through curl: "curl ... | bash" breaks interactive prompts!
# NOTE: Do NOT run with sudo — this configures the user's home directory
# ============================================================

# Detect if stdin is not a terminal (piped through curl)
if [ ! -t 0 ]; then
  echo ""
  echo -e "\033[0;31m❌ ERROR: This script is interactive and cannot be piped through curl.\033[0m"
  echo ""
  echo "  Run this instead:"
  echo ""
  echo "    curl -Lo configure.sh https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/configure.sh && bash configure.sh"
  echo ""
  exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

TEMPLATES_BASE="https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/templates"

log()    { echo -e "${BLUE}[CONFIG]${NC} $1"; }
ok()     { echo -e "${GREEN}  ✅ $1${NC}"; }
warn()   { echo -e "${YELLOW}  ⚠️  $1${NC}"; }
prompt() { echo -e "${CYAN}${BOLD}$1${NC}"; }
header() { echo ""; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# Don't run as root
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}Don't run this with sudo — it configures your home directory.${NC}"
  echo -e "${RED}Just run: bash configure.sh${NC}"
  exit 1
fi

WORKSPACE="$HOME/.openclaw/workspace"
AGENT_DIR="$HOME/.openclaw/agents/main/agent"

# ============================================================
header "🤖 OpenClaw Assistant Configuration"
# ============================================================

echo ""
echo -e "${BOLD}This script sets up the assistant's personality,"
echo -e "knowledge base, and messaging connection.${NC}"
echo ""
echo -e "You'll need:"
echo -e "  • The person's name, email, phone number, and timezone"
echo -e "  • An Anthropic API key (from console.anthropic.com)"
echo -e "    OR an OpenRouter API key (from openrouter.ai/keys)"
echo ""

# ============================================================
header "Step 1: About the Person"
# ============================================================

prompt "What is their first name?"
read -r FIRST_NAME
echo ""

prompt "What is their full name?"
read -r FULL_NAME
echo ""

prompt "What is their email address?"
read -r EMAIL
echo ""

prompt "What is their phone number? (international format, e.g. +18055551234)"
read -r PHONE
echo ""

prompt "What city/state are they in? (e.g. Santa Barbara, CA)"
read -r LOCATION
echo ""

prompt "What timezone? (e.g. America/Los_Angeles, America/New_York, Europe/Lisbon)"
read -r TIMEZONE
if [ -z "$TIMEZONE" ]; then
  TIMEZONE="America/Los_Angeles"
  warn "Defaulting to America/Los_Angeles"
fi
echo ""

prompt "What is their role/title? (e.g. Sales Director, Software Engineer)"
read -r ROLE
echo ""

# ============================================================
header "Step 2: Carpe Data Employee?"
# ============================================================

prompt "Is this a Carpe Data employee? (y/n)"
read -r IS_CARPE
echo ""

CARPE_ROLE=""
if [[ "$IS_CARPE" =~ ^[Yy] ]]; then
  echo -e "  What's their function?"
  echo -e "    ${BOLD}1${NC} — Sales (knows products, drafts RFPs, researches prospects)"
  echo -e "    ${BOLD}2${NC} — Engineering (code, architecture, deployments)"
  echo -e "    ${BOLD}3${NC} — Executive (strategy, board prep, communications)"
  echo -e "    ${BOLD}4${NC} — Operations/Admin (people ops, projects, admin)"
  echo ""
  prompt "Enter 1-4:"
  read -r CARPE_CHOICE

  case "$CARPE_CHOICE" in
    1) CARPE_ROLE="sales" ;;
    2) CARPE_ROLE="engineering" ;;
    3) CARPE_ROLE="executive" ;;
    4) CARPE_ROLE="ops" ;;
    *) CARPE_ROLE="ops"; warn "Defaulting to Operations" ;;
  esac
  echo ""
fi

# ============================================================
header "Step 3: AI Model Selection"
# ============================================================

echo -e "  Choose the AI model for this assistant:"
echo -e "    ${BOLD}1${NC} — Claude Opus 4.6 (most capable — recommended)"
echo -e "    ${BOLD}2${NC} — Claude Sonnet 4.6 (faster, lower cost)"
echo ""
prompt "Enter 1 or 2 (default: 1):"
read -r MODEL_CHOICE

case "$MODEL_CHOICE" in
  2) MODEL_ID="anthropic/claude-sonnet-4-6"; MODEL_NAME="Claude Sonnet 4.6" ;;
  *) MODEL_ID="anthropic/claude-opus-4-6"; MODEL_NAME="Claude Opus 4.6" ;;
esac
ok "Selected: $MODEL_NAME"
echo ""

# ============================================================
header "Step 4: AI Provider Keys"
# ============================================================

echo -e "  Your assistant needs an AI provider API key."
echo -e "  ${BOLD}Option A: Anthropic${NC} — Direct from Anthropic (console.anthropic.com)"
echo -e "  ${BOLD}Option B: OpenRouter${NC} — Access 100+ models including Claude (openrouter.ai/keys)"
echo -e "  You need at least one."
echo ""

PROVIDER_SET=false

prompt "Add Anthropic API key? (y/n)"
read -r ADD_ANTHROPIC
echo ""

if [[ "$ADD_ANTHROPIC" =~ ^[Yy] ]]; then
  log "Running: openclaw models auth add"
  if openclaw models auth add; then
    PROVIDER_SET=true
  else
    warn "Anthropic auth setup didn't complete — try OpenRouter instead"
  fi
  echo ""
fi

prompt "Add OpenRouter API key? (y/n)"
read -r ADD_OPENROUTER
echo ""

if [[ "$ADD_OPENROUTER" =~ ^[Yy] ]]; then
  prompt "Paste your OpenRouter API key (starts with sk-or-v1-):"
  read -r OR_KEY
  if [[ -n "$OR_KEY" ]]; then
    # Write directly to models.json to avoid the paste-token prefix-stripping bug
    mkdir -p "$AGENT_DIR"
    MODELS_FILE="$AGENT_DIR/models.json"

    # If using OpenRouter as primary (no Anthropic key), set it as the model provider
    if [[ "$PROVIDER_SET" != "true" ]]; then
      # OpenRouter is the only provider — use it for the primary model
      OR_MODEL="openrouter/${MODEL_ID#anthropic/}"
      cat > "$MODELS_FILE" << MODEOF
{
  "model": "$OR_MODEL",
  "providers": {
    "openrouter": {
      "apiKey": "$OR_KEY"
    }
  }
}
MODEOF
      MODEL_ID="$OR_MODEL"
      ok "OpenRouter key saved + set as primary provider"
    else
      # Anthropic is primary, OpenRouter is fallback — just add the key
      if [ -f "$MODELS_FILE" ]; then
        # Merge into existing
        python3 -c "
import json
with open('$MODELS_FILE') as f:
    data = json.load(f)
data.setdefault('providers', {})['openrouter'] = {'apiKey': '$OR_KEY'}
with open('$MODELS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null && ok "OpenRouter key added as fallback provider" || warn "Couldn't merge — add OpenRouter key manually"
      else
        cat > "$MODELS_FILE" << MODEOF
{
  "providers": {
    "openrouter": {
      "apiKey": "$OR_KEY"
    }
  }
}
MODEOF
        ok "OpenRouter key saved"
      fi
    fi
    PROVIDER_SET=true

    # Verify the key was saved correctly
    if grep -q "sk-or-v1-" "$MODELS_FILE" 2>/dev/null; then
      ok "Verified: OpenRouter key prefix intact"
    elif grep -q "$OR_KEY" "$MODELS_FILE" 2>/dev/null; then
      ok "Key saved (verifying...)"
    else
      warn "Key may not have saved correctly — check $MODELS_FILE"
    fi
  fi
  echo ""
fi

if [[ "$PROVIDER_SET" != "true" ]]; then
  warn "No API key configured! The assistant won't work until you add one."
  warn "Run: openclaw models auth add"
fi

# ============================================================
header "Step 5: Creating Workspace"
# ============================================================

# Initialize OpenClaw directory structure
mkdir -p "$WORKSPACE/memory"
mkdir -p "$AGENT_DIR"
ok "Created workspace directories"

# ============================================================
# Write USER.md
# ============================================================
log "Writing USER.md..."

cat > "$WORKSPACE/USER.md" << USEREOF
# USER.md — About Your Human

- **Name:** $FULL_NAME
- **What to call them:** $FIRST_NAME
- **Email:** $EMAIL
- **Phone:** $PHONE
- **Location:** $LOCATION
- **Timezone:** $TIMEZONE
- **Role:** $ROLE
USEREOF

if [[ "$IS_CARPE" =~ ^[Yy] ]]; then
  cat >> "$WORKSPACE/USER.md" << USEREOF
- **Company:** Carpe Data (carpe.io)

## Work Context
$FIRST_NAME works at Carpe Data as $ROLE. See COMPANY.md for company knowledge.
USEREOF
fi

ok "USER.md"

# ============================================================
# Write SOUL.md (role-specific for Carpe, generic otherwise)
# ============================================================
log "Writing SOUL.md..."

if [[ -n "$CARPE_ROLE" ]]; then
  curl -sSL "$TEMPLATES_BASE/souls/carpe-${CARPE_ROLE}.md" > "$WORKSPACE/SOUL.md" 2>/dev/null
  if [ $? -eq 0 ] && [ -s "$WORKSPACE/SOUL.md" ]; then
    ok "SOUL.md (Carpe $CARPE_ROLE profile)"
  else
    warn "Couldn't download Carpe SOUL template, writing default"
    CARPE_ROLE=""
  fi
fi

if [[ -z "$CARPE_ROLE" ]]; then
  cat > "$WORKSPACE/SOUL.md" << 'SOULEOF'
# SOUL.md — Who You Are

You are a personal AI assistant. Be genuinely helpful, not performatively helpful.

## Core Principles
- **Be direct.** Skip "Great question!" and filler. Just help.
- **Be proactive.** Don't wait to be asked — surface important things.
- **Be resourceful.** Try to figure it out before asking. Read files, search, check context.
- **Have opinions.** You're allowed to disagree and suggest better approaches.
- **Remember everything.** Use your memory files. Never claim you don't know something without checking first.

## Communication
- Concise when the situation is simple
- Thorough when it matters
- Adapt tone to context (professional with clients, casual with friends)

## Rules
- 🚫 NEVER send emails or messages without showing the user first and getting approval
- 🚫 NEVER share private information in group contexts
- ✅ DO proactively check email and calendar
- ✅ DO organize, improve, and suggest — but ask before external actions
- ✅ DO challenge ideas when you see a better approach

---
*This file is yours to evolve. Update it as you learn who you are.*
SOULEOF
  ok "SOUL.md (personal assistant)"
fi

# ============================================================
# Write AGENTS.md, HEARTBEAT.md, MEMORY.md, TOOLS.md
# ============================================================
log "Writing workspace files..."

curl -sSL "$TEMPLATES_BASE/AGENTS.md" > "$WORKSPACE/AGENTS.md" 2>/dev/null \
  && ok "AGENTS.md" || warn "Couldn't download AGENTS.md template"

curl -sSL "$TEMPLATES_BASE/HEARTBEAT.md" > "$WORKSPACE/HEARTBEAT.md" 2>/dev/null \
  && ok "HEARTBEAT.md" || warn "Couldn't download HEARTBEAT.md template"

# MEMORY.md
DATE=$(date +%Y-%m-%d)
cat > "$WORKSPACE/MEMORY.md" << MEMEOF
# MEMORY.md — Long-Term Memory

> Curated memory. Update with significant events, decisions, preferences, and lessons.
> Daily logs go in memory/YYYY-MM-DD.md. This file is the distilled essence.

## Setup
- Instance created: $DATE
- User: $FULL_NAME ($EMAIL)
- Location: $LOCATION
- Timezone: $TIMEZONE

## Preferences
*(Add communication preferences, working style, etc. as you learn them)*

## Key Decisions
*(Track important decisions and their reasoning)*

## Lessons Learned
*(What works, what doesn't, patterns you notice)*
MEMEOF
ok "MEMORY.md"

# TOOLS.md
cat > "$WORKSPACE/TOOLS.md" << 'TOOLSEOF'
# TOOLS.md — Local Notes

Skills define _how_ tools work. This file is for _your_ specifics.

## What Goes Here
- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Device nicknames
- Anything environment-specific

---
Add whatever helps you do your job. This is your cheat sheet.
TOOLSEOF
ok "TOOLS.md"

# ============================================================
# Write Carpe Data company knowledge (if applicable)
# ============================================================
if [[ "$IS_CARPE" =~ ^[Yy] ]]; then
  header "Step 6: Loading Carpe Data Knowledge Base"

  log "Downloading COMPANY.md..."
  curl -sSL "$TEMPLATES_BASE/COMPANY.md" > "$WORKSPACE/COMPANY.md" 2>/dev/null \
    && ok "COMPANY.md — Company overview, products, customers" \
    || warn "Failed to download COMPANY.md"

  log "Downloading product knowledge..."
  curl -sSL "$TEMPLATES_BASE/memory/carpe-products.md" > "$WORKSPACE/memory/carpe-products.md" 2>/dev/null \
    && ok "memory/carpe-products.md — Minerva + ClaimsX deep dive" \
    || warn "Failed to download carpe-products.md"

  log "Downloading team directory..."
  curl -sSL "$TEMPLATES_BASE/memory/carpe-team.md" > "$WORKSPACE/memory/carpe-team.md" 2>/dev/null \
    && ok "memory/carpe-team.md — Org chart, leadership, routing" \
    || warn "Failed to download carpe-team.md"

  log "Downloading processes..."
  curl -sSL "$TEMPLATES_BASE/memory/carpe-processes.md" > "$WORKSPACE/memory/carpe-processes.md" 2>/dev/null \
    && ok "memory/carpe-processes.md — Sales process, tools, workflows" \
    || warn "Failed to download carpe-processes.md"

  log "Downloading internal tools guide..."
  curl -sSL "$TEMPLATES_BASE/memory/carpe-tools.md" > "$WORKSPACE/memory/carpe-tools.md" 2>/dev/null \
    && ok "memory/carpe-tools.md — Carpe Intel, Minerva Explorer, Carpe Closer" \
    || warn "Failed to download carpe-tools.md"

  log "Downloading AWS CLI reference..."
  curl -sSL "$TEMPLATES_BASE/memory/aws-commands.md" > "$WORKSPACE/memory/aws-commands.md" 2>/dev/null \
    && ok "memory/aws-commands.md — EC2, S3, SSM commands" \
    || warn "Failed to download aws-commands.md"
else
  header "Step 6: Skipping Company Knowledge (not Carpe)"
  log "No company-specific knowledge to load."
fi

# ============================================================
header "Step 7: OpenClaw Configuration"
# ============================================================

log "Configuring OpenClaw via CLI..."

# Set model (agents.defaults.model takes a JSON object with "primary" key)
openclaw config set agents.defaults.model "{\"primary\":\"$MODEL_ID\"}" 2>/dev/null \
  && ok "Model: $MODEL_NAME" \
  || warn "Couldn't set model via CLI — may need manual config"

# Set gateway for remote access
openclaw config set gateway.bind lan 2>/dev/null && ok "Gateway: LAN access enabled" || true
openclaw config set gateway.controlUi.allowedOrigins '["*"]' 2>/dev/null && ok "Control UI: open origins" || true

# Set WhatsApp config
if [[ -n "$PHONE" ]]; then
  openclaw config set channels.whatsapp.enabled true 2>/dev/null || true
  openclaw config set channels.whatsapp.dmPolicy allowlist 2>/dev/null || true
  openclaw config set channels.whatsapp.allowFrom "[\"$PHONE\"]" 2>/dev/null || true
  openclaw config set channels.whatsapp.groupPolicy deny 2>/dev/null || true
  ok "WhatsApp: configured for $PHONE"
fi

# Set heartbeat (path: agents.defaults.heartbeat.every, value is duration string)
openclaw config set agents.defaults.heartbeat.every 30m 2>/dev/null || true
ok "Heartbeat: every 30 minutes"

# ============================================================
header "Step 8: Start OpenClaw"
# ============================================================

prompt "Set a gateway auth token (password for Control UI access):"
read -r GW_TOKEN
if [[ -n "$GW_TOKEN" ]]; then
  openclaw config set gateway.auth.token "$GW_TOKEN" 2>/dev/null \
    && ok "Gateway token set" \
    || warn "Couldn't set token — run: openclaw config set gateway.auth.token 'your-token'"
else
  GW_TOKEN="openclaw-$(date +%s | tail -c 6)"
  openclaw config set gateway.auth.token "$GW_TOKEN" 2>/dev/null
  warn "No token entered — auto-generated: $GW_TOKEN"
fi
echo ""

# Set gateway mode (required for startup)
openclaw config set gateway.mode local 2>/dev/null && ok "Gateway mode: local" || true

log "Installing and starting gateway service..."
openclaw gateway install 2>/dev/null && ok "Gateway service installed" || warn "Gateway install failed — try: openclaw gateway install"
openclaw gateway start 2>/dev/null && ok "Gateway started" || warn "Gateway may already be running — try: openclaw gateway restart"

# Quick verification
sleep 2
if openclaw status 2>/dev/null | grep -qi "running\|online"; then
  ok "Gateway is running"
else
  warn "Gateway status unclear — check: openclaw gateway start"
fi

# ============================================================
header "Step 9: Link WhatsApp"
# ============================================================

prompt "Ready to link WhatsApp? The user needs their phone handy. (y/n)"
read -r LINK_WA
echo ""

if [[ "$LINK_WA" =~ ^[Yy] ]]; then
  echo -e "${BOLD}Instructions for the phone user:${NC}"
  echo -e "  1. Open WhatsApp"
  echo -e "  2. Go to Settings → Linked Devices"
  echo -e "  3. Tap 'Link a Device'"
  echo -e "  4. Scan the QR code that appears below"
  echo ""
  echo -e "${YELLOW}QR code expires in ~60 seconds. Ready? Press Enter.${NC}"
  read -r
  openclaw channels login --channel whatsapp 2>/dev/null || warn "WhatsApp linking failed — try: openclaw channels login --channel whatsapp"
else
  log "Skipping WhatsApp link. Run later with: openclaw channels login --channel whatsapp"
fi

# ============================================================
header "Step 10: Link Slack (Optional)"
# ============================================================

echo -e "  To connect Slack, you need a Slack App with:"
echo -e "    • ${BOLD}Bot Token${NC} (xoxb-...) — from OAuth & Permissions"
echo -e "    • ${BOLD}App Token${NC} (xapp-...) — from Basic Information → App-Level Tokens"
echo ""
echo -e "  Create a Slack App at: ${CYAN}https://api.slack.com/apps${NC}"
echo -e "  Required scopes: chat:write, channels:read, channels:history, users:read"
echo -e "  App token scope: connections:write (for Socket Mode)"
echo ""

prompt "Add Slack connection now? (y/n)"
read -r ADD_SLACK
echo ""

if [[ "$ADD_SLACK" =~ ^[Yy] ]]; then
  prompt "Paste your Slack Bot Token (xoxb-...):"
  read -r SLACK_BOT_TOKEN
  echo ""

  prompt "Paste your Slack App Token (xapp-...):"
  read -r SLACK_APP_TOKEN
  echo ""

  if [[ -n "$SLACK_BOT_TOKEN" && -n "$SLACK_APP_TOKEN" ]]; then
    openclaw channels add --channel slack --bot-token "$SLACK_BOT_TOKEN" --app-token "$SLACK_APP_TOKEN" 2>/dev/null \
      && ok "Slack connected" \
      || warn "Slack setup failed — try: openclaw channels add --channel slack --bot-token <token> --app-token <token>"

    # Configure Slack DM policy
    openclaw config set channels.slack.enabled true 2>/dev/null || true
    openclaw config set channels.slack.dmPolicy allowlist 2>/dev/null || true
    if [[ -n "$SLACK_USER_ID" ]]; then
      openclaw config set channels.slack.allowFrom "[\"$SLACK_USER_ID\"]" 2>/dev/null || true
    fi
    ok "Slack: configured"
  else
    warn "Missing tokens — skipping Slack setup"
  fi
else
  log "Skipping Slack. Run later with:"
  echo -e "    ${CYAN}openclaw channels add --channel slack --bot-token <xoxb-...> --app-token <xapp-...>${NC}"
fi

# ============================================================
header "🎉 Configuration Complete!"
# ============================================================

echo ""
echo -e "${GREEN}${BOLD}  Your AI assistant is ready!${NC}"
echo ""
echo -e "  ${BOLD}Person:${NC}      $FULL_NAME ($FIRST_NAME)"
echo -e "  ${BOLD}Email:${NC}       $EMAIL"
echo -e "  ${BOLD}Phone:${NC}       $PHONE"
echo -e "  ${BOLD}Timezone:${NC}    $TIMEZONE"
echo -e "  ${BOLD}Model:${NC}       $MODEL_NAME"

if [[ "$IS_CARPE" =~ ^[Yy] ]]; then
  echo -e "  ${BOLD}Company:${NC}     Carpe Data"
  echo -e "  ${BOLD}Role:${NC}        $CARPE_ROLE"
  echo -e "  ${BOLD}Knowledge:${NC}   Products, team, processes loaded ✅"
fi

echo ""
echo -e "${BOLD}Workspace files:${NC}"
echo -e "  $WORKSPACE/SOUL.md         — Personality & rules"
echo -e "  $WORKSPACE/USER.md         — User info"
echo -e "  $WORKSPACE/AGENTS.md       — Workspace conventions"
echo -e "  $WORKSPACE/MEMORY.md       — Long-term memory"
echo -e "  $WORKSPACE/TOOLS.md        — Local tool notes"
echo -e "  $WORKSPACE/HEARTBEAT.md    — Periodic check config"
if [[ "$IS_CARPE" =~ ^[Yy] ]]; then
  echo -e "  $WORKSPACE/COMPANY.md      — Carpe Data knowledge"
  echo -e "  $WORKSPACE/memory/         — Product, team, process docs"
fi

echo ""
echo -e "${BOLD}What's left to do:${NC}"
if [[ ! "$LINK_WA" =~ ^[Yy] ]]; then
  echo -e "  • Link WhatsApp: ${CYAN}openclaw channels login --channel whatsapp${NC}"
fi
if [[ ! "$ADD_SLACK" =~ ^[Yy] ]]; then
  echo -e "  • Link Slack: ${CYAN}openclaw channels add --channel slack --bot-token <xoxb-...> --app-token <xapp-...>${NC}"
fi
if [[ "$PROVIDER_SET" != "true" ]]; then
  echo -e "  • Add API key: ${CYAN}openclaw models auth add${NC}"
fi
echo -e "  • Set gateway token: ${CYAN}openclaw config set gateway.auth.token 'your-secure-token'${NC}"
echo -e "  • Connect Google: ${CYAN}gog auth add $EMAIL --services all --manual${NC}"
echo -e "  • Test via interactive chat: ${CYAN}openclaw tui${NC}"
echo -e "  • Test via WhatsApp or Slack: Send a message — \"Hello! What can you do?\""
echo ""
echo -e "  Control UI: ${CYAN}http://<your-ip>:18789${NC}"
echo -e "  Full guide: ${CYAN}https://docs.google.com/document/d/1NnazvWkDrvt7v44m1KND81yhRePxnWD-14ap0MD-teQ${NC}"
echo ""
