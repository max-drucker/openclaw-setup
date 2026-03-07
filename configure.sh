#!/usr/bin/env bash
# ============================================================
# OpenClaw Configure Script — Phase 2
# Sets up the assistant's workspace, personality, and config
# Run AFTER setup.sh (which installs all tools)
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/configure.sh | bash
#
# Or download first:
#   curl -Lo configure.sh https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/configure.sh
#   bash configure.sh
#
# NOTE: Do NOT run with sudo — this configures the user's home directory
# ============================================================

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
CONFIG="$HOME/.openclaw/openclaw.json"

# ============================================================
header "🤖 OpenClaw Assistant Configuration"
# ============================================================

echo ""
echo -e "${BOLD}This script will set up your AI assistant's personality,"
echo -e "knowledge base, and WhatsApp connection.${NC}"
echo ""
echo -e "You'll need:"
echo -e "  • The person's name, email, phone number, and timezone"
echo -e "  • An Anthropic API key (from console.anthropic.com)"
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
header "Step 3: API Key"
# ============================================================

prompt "Do you want to add the Anthropic API key now? (y/n)"
read -r ADD_KEY
echo ""

if [[ "$ADD_KEY" =~ ^[Yy] ]]; then
  log "Running: openclaw auth add anthropic"
  openclaw auth add anthropic
  echo ""
fi

# ============================================================
header "Step 4: Creating Workspace"
# ============================================================

# Initialize OpenClaw if not already done
if [ ! -d "$HOME/.openclaw" ]; then
  log "Initializing OpenClaw..."
  openclaw status 2>/dev/null || true
fi

# Create workspace directories
mkdir -p "$WORKSPACE/memory"
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
# Write AGENTS.md
# ============================================================
log "Writing AGENTS.md..."
curl -sSL "$TEMPLATES_BASE/AGENTS.md" > "$WORKSPACE/AGENTS.md" 2>/dev/null
if [ $? -eq 0 ] && [ -s "$WORKSPACE/AGENTS.md" ]; then
  ok "AGENTS.md"
else
  warn "Couldn't download AGENTS.md template"
fi

# ============================================================
# Write HEARTBEAT.md
# ============================================================
log "Writing HEARTBEAT.md..."
curl -sSL "$TEMPLATES_BASE/HEARTBEAT.md" > "$WORKSPACE/HEARTBEAT.md" 2>/dev/null
if [ $? -eq 0 ] && [ -s "$WORKSPACE/HEARTBEAT.md" ]; then
  ok "HEARTBEAT.md"
else
  warn "Couldn't download HEARTBEAT.md template"
fi

# ============================================================
# Write MEMORY.md
# ============================================================
log "Writing MEMORY.md..."
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

# ============================================================
# Write Carpe Data company knowledge (if applicable)
# ============================================================
if [[ "$IS_CARPE" =~ ^[Yy] ]]; then
  header "Step 5: Loading Carpe Data Knowledge Base"

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
else
  header "Step 5: Skipping Company Knowledge (not Carpe)"
  log "No company-specific knowledge to load."
fi

# ============================================================
header "Step 6: OpenClaw Configuration"
# ============================================================

log "Writing openclaw.json..."

# Create config directory if needed
mkdir -p "$(dirname "$CONFIG")"

# Only write config if it doesn't exist or is default
if [ ! -f "$CONFIG" ] || [ "$(wc -c < "$CONFIG")" -lt 50 ]; then
  cat > "$CONFIG" << CONFEOF
{
  "model": "anthropic/claude-opus-4-6",
  "timezone": "$TIMEZONE",
  "channels": {
    "whatsapp": {
      "enabled": true,
      "dmPolicy": "allowlist",
      "allowFrom": ["$PHONE"],
      "groupPolicy": "deny"
    }
  },
  "gateway": {
    "controlUi": {
      "allowedOrigins": ["*"]
    }
  },
  "heartbeat": {
    "enabled": true,
    "intervalMinutes": 30
  }
}
CONFEOF
  ok "openclaw.json (with WhatsApp for $PHONE)"
else
  warn "openclaw.json already exists — not overwriting"
  log "You may need to manually add WhatsApp config for $PHONE"
fi

# ============================================================
header "Step 7: Start OpenClaw"
# ============================================================

log "Starting gateway..."
openclaw gateway start 2>/dev/null && ok "Gateway started" || warn "Gateway may already be running — try: openclaw gateway restart"

# ============================================================
header "Step 8: Link WhatsApp"
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
  openclaw whatsapp link
else
  log "Skipping WhatsApp link. Run later: openclaw whatsapp link"
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
echo -e "  ${BOLD}Model:${NC}       Claude Opus 4.6"

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
echo -e "  $WORKSPACE/HEARTBEAT.md    — Periodic check config"
if [[ "$IS_CARPE" =~ ^[Yy] ]]; then
  echo -e "  $WORKSPACE/COMPANY.md      — Carpe Data knowledge"
  echo -e "  $WORKSPACE/memory/         — Product, team, process docs"
fi

echo ""
echo -e "${BOLD}What's left to do manually:${NC}"
if [[ ! "$LINK_WA" =~ ^[Yy] ]]; then
  echo -e "  • Link WhatsApp: ${CYAN}openclaw whatsapp link${NC}"
fi
if [[ ! "$ADD_KEY" =~ ^[Yy] ]]; then
  echo -e "  • Add API key: ${CYAN}openclaw auth add anthropic${NC}"
fi
echo -e "  • Connect Google: ${CYAN}gog auth add $EMAIL --services all --manual${NC}"
echo -e "    (See the setup guide for full Google OAuth instructions)"
echo -e "  • Test it: Send a WhatsApp message — \"Hello! What can you do?\""
echo ""
echo -e "  Full guide: ${CYAN}https://docs.google.com/document/d/1NnazvWkDrvt7v44m1KND81yhRePxnWD-14ap0MD-teQ${NC}"
echo ""
