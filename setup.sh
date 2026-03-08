#!/usr/bin/env bash
# ============================================================
# OpenClaw EC2 Setup Script
# Installs all tools on a fresh Ubuntu 24.04 LTS instance
# Tested: March 7-8, 2026 on AWS EC2 (t3.medium, Ubuntu 24.04)
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/setup.sh | sudo bash
#
# Or download and review first:
#   curl -Lo setup.sh https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/setup.sh
#   less setup.sh
#   sudo bash setup.sh
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

RESULTS=()

log()    { echo -e "${BLUE}[SETUP]${NC} $1"; }
ok()     { echo -e "${GREEN}  ✅ $1${NC}"; RESULTS+=("✅ $1"); }
fail()   { echo -e "${RED}  ❌ $1${NC}"; RESULTS+=("❌ $1"); }
warn()   { echo -e "${YELLOW}  ⚠️  $1${NC}"; }
header() { echo ""; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# Check we're running as root/sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run with sudo: sudo bash setup.sh${NC}"
  exit 1
fi

header "Step 1/11: System Update"
apt update && apt upgrade -y && ok "System updated" || fail "System update"

header "Step 2/11: Node.js 22"
if command -v node &>/dev/null && node --version | grep -q "v22\|v23\|v24\|v25"; then
  warn "Node.js already installed: $(node --version) — skipping"
  ok "Node.js $(node --version)"
else
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt install -y nodejs && ok "Node.js $(node --version)" || fail "Node.js"
fi

header "Step 3/11: OpenClaw"
npm install -g openclaw@latest && ok "OpenClaw $(openclaw --version 2>/dev/null || echo 'installed')" || fail "OpenClaw"

header "Step 4/11: Google Workspace CLI (gog)"
cd /tmp
curl -Lo gog.tar.gz https://github.com/steipete/gogcli/releases/download/v0.11.0/gogcli_0.11.0_linux_amd64.tar.gz \
  && tar xzf gog.tar.gz -C /usr/local/bin \
  && rm gog.tar.gz \
  && ok "gog $(gog --version 2>/dev/null | head -1 || echo 'installed')" \
  || fail "gog CLI"

header "Step 5/11: Supabase CLI"
cd /tmp
curl -Lo supabase.deb https://github.com/supabase/cli/releases/download/v2.75.0/supabase_2.75.0_linux_amd64.deb \
  && dpkg -i supabase.deb \
  && rm supabase.deb \
  && ok "Supabase $(supabase --version 2>/dev/null || echo 'installed')" \
  || fail "Supabase CLI"

header "Step 6/11: GitHub CLI"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt update && apt install -y gh \
  && ok "GitHub CLI $(gh --version 2>/dev/null | head -1 || echo 'installed')" \
  || fail "GitHub CLI"

header "Step 7/11: Railway CLI"
cd /tmp
curl -Lo railway.deb https://github.com/railwayapp/cli/releases/download/v4.31.0/railway-v4.31.0-amd64.deb \
  && dpkg -i railway.deb \
  && rm railway.deb \
  && ok "Railway $(railway --version 2>/dev/null || echo 'installed')" \
  || fail "Railway CLI"

header "Step 8/11: System Utilities (needed by later steps)"
apt install -y jq curl wget unzip git htop tmux tree pandoc && ok "System utilities + pandoc" || fail "System utilities"

header "Step 9/11: AWS CLI v2"
log "Installing AWS CLI..."
cd /tmp
curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscli.zip \
  && unzip -qo awscli.zip \
  && ./aws/install --update 2>/dev/null \
  && rm -rf awscli.zip aws/ \
  && ok "AWS CLI $(aws --version 2>/dev/null | awk '{print $1}' || echo 'installed')" \
  || fail "AWS CLI"

header "Step 10/11: npm Global Tools"
log "Installing Vercel..."
npm i -g vercel && ok "Vercel" || fail "Vercel"

log "Installing Claude Code..."
npm i -g @anthropic-ai/claude-code && ok "Claude Code" || fail "Claude Code"

log "Installing Salesforce CLI..."
npm i -g @salesforce/cli && ok "Salesforce CLI" || fail "Salesforce CLI"

log "Installing OpenAI Codex..."
npm i -g @openai/codex && ok "OpenAI Codex" || fail "OpenAI Codex"

log "Installing md-to-pdf..."
npm i -g md-to-pdf && ok "md-to-pdf" || fail "md-to-pdf"

header "Step 11/11: Python & Verify"
apt install -y python3-pip python3-venv && ok "Python 3 + pip + venv" || fail "Python tools"

log "Verifying installation..."
echo ""
ALL_GOOD=true
for cmd in openclaw node npm gog vercel supabase gh railway claude sf codex aws pandoc python3 jq git tmux; do
  if command -v $cmd &>/dev/null; then
    VER=$($cmd --version 2>/dev/null | head -1 || echo "ok")
    echo -e "  ${GREEN}✅${NC} $cmd — $VER"
  else
    echo -e "  ${RED}❌${NC} $cmd — NOT FOUND"
    ALL_GOOD=false
  fi
done

# ============================================================
# Summary
# ============================================================
header "Installation Summary"
for r in "${RESULTS[@]}"; do
  echo -e "  $r"
done

echo ""
if [ "$ALL_GOOD" = true ]; then
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}  ALL TOOLS INSTALLED SUCCESSFULLY 🎉${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
else
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}  SOME TOOLS FAILED — check output above${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "  If you saw 'kernel update — reboot required':"
echo "    sudo reboot"
echo "    (SSH back in after 30 seconds)"
echo ""
echo -e "  Then run ${BOLD}Phase 2 — Configure the assistant:${NC}"
echo ""
echo "    curl -Lo configure.sh https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/configure.sh && bash configure.sh"
echo ""
echo "  This sets up the assistant's personality, knowledge base,"
echo "  WhatsApp/Slack connections, and API key — all interactive."
echo ""
echo "  Full guide: https://docs.google.com/document/d/1NnazvWkDrvt7v44m1KND81yhRePxnWD-14ap0MD-teQ"
echo ""
