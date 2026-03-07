#!/bin/bash
# ============================================================================
# OpenClaw Lightsail Setup Script
# ============================================================================
# One-command setup for new OpenClaw instances on AWS Lightsail (Ubuntu)
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/max-drucker/openclaw-setup/main/lightsail-setup.sh | bash
#   — or —
#   bash lightsail-setup.sh
#
# Prerequisites:
#   - AWS Lightsail instance (Ubuntu, 2GB+ RAM recommended)
#   - OpenClaw blueprint OR Node.js 20+ pre-installed
#   - Run as a user with sudo access (default 'ubuntu' user is fine)
#
# What this script installs:
#   - OpenClaw (latest)
#   - gog CLI (Google Workspace: Gmail, Calendar, Drive, Docs)
#   - Vercel CLI (web app deployment)
#   - Supabase CLI (database management)
#   - GitHub CLI (gh)
#   - Claude Code (AI coding agent)
#   - Python 3 + pip + venv
#   - Salesforce CLI (optional, for Carpe team members)
#
# Author: Judah (Max Drucker's AI assistant)
# Date: March 2026
# ============================================================================

set -euo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
info() { echo -e "${BLUE}[→]${NC} $1"; }

# --- Pre-flight checks ---
echo ""
echo "============================================"
echo "  OpenClaw Lightsail Setup"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================"
echo ""

# Check we're on Linux
if [[ "$(uname -s)" != "Linux" ]]; then
    err "This script is for Ubuntu/Linux (Lightsail). You're on $(uname -s)."
    err "For macOS, use: brew install openclaw"
    exit 1
fi

# Check sudo access
if ! sudo -n true 2>/dev/null; then
    warn "This script needs sudo access. You may be prompted for your password."
fi

# --- Step 1: System update ---
info "Updating system packages..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
log "System packages updated"

# --- Step 2: Node.js (if not present) ---
if command -v node &>/dev/null; then
    NODE_VER=$(node --version)
    log "Node.js already installed: ${NODE_VER}"
    
    # Check minimum version (need 20+)
    NODE_MAJOR=$(echo "$NODE_VER" | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_MAJOR" -lt 20 ]; then
        warn "Node.js ${NODE_VER} is too old. Installing Node 22..."
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        sudo apt-get install -y nodejs
        log "Node.js updated to $(node --version)"
    fi
else
    info "Installing Node.js 22..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
    log "Node.js $(node --version) installed"
fi

# --- Step 3: OpenClaw ---
info "Installing/updating OpenClaw..."
sudo npm install -g openclaw@latest --no-fund --no-audit 2>&1 | tail -1
OPENCLAW_VER=$(openclaw --version 2>/dev/null || echo "unknown")
log "OpenClaw installed: ${OPENCLAW_VER}"

# --- Step 4: Google Workspace CLI (gog) ---
info "Installing gog CLI (Google Workspace)..."
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
    GOG_URL="https://github.com/steipete/gogcli/releases/latest/download/gog_linux_amd64.tar.gz"
elif [ "$ARCH" = "arm64" ]; then
    GOG_URL="https://github.com/steipete/gogcli/releases/latest/download/gog_linux_arm64.tar.gz"
else
    warn "Unknown architecture: ${ARCH}. Skipping gog install."
    GOG_URL=""
fi

if [ -n "$GOG_URL" ]; then
    curl -sSL "$GOG_URL" | sudo tar xz -C /usr/local/bin 2>/dev/null && \
        log "gog CLI installed: $(gog --version 2>/dev/null | head -1)" || \
        warn "gog install failed — can be installed manually later"
fi

# --- Step 5: Vercel CLI ---
info "Installing Vercel CLI..."
sudo npm install -g vercel --no-fund --no-audit 2>&1 | tail -1
log "Vercel CLI installed: $(vercel --version 2>/dev/null | head -1)"

# --- Step 6: Supabase CLI ---
info "Installing Supabase CLI..."
sudo npm install -g supabase --no-fund --no-audit 2>&1 | tail -1
log "Supabase CLI installed"

# --- Step 7: GitHub CLI ---
info "Installing GitHub CLI..."
if command -v gh &>/dev/null; then
    log "GitHub CLI already installed: $(gh --version | head -1)"
else
    sudo apt-get install -y gh -qq 2>/dev/null || {
        # Fallback: add GitHub's apt repo
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt-get update -qq && sudo apt-get install -y gh -qq
    }
    log "GitHub CLI installed: $(gh --version | head -1)"
fi

# --- Step 8: Claude Code ---
info "Installing Claude Code (AI coding agent)..."
sudo npm install -g @anthropic-ai/claude-code --no-fund --no-audit 2>&1 | tail -1
log "Claude Code installed"

# --- Step 9: Python tools ---
info "Installing Python tools..."
sudo apt-get install -y python3-pip python3-venv python3-dev -qq
log "Python $(python3 --version) + pip + venv installed"

# --- Step 10: Salesforce CLI (optional) ---
info "Installing Salesforce CLI..."
sudo npm install -g @salesforce/cli --no-fund --no-audit 2>&1 | tail -1
log "Salesforce CLI installed"

# --- Step 11: Common utilities ---
info "Installing common utilities..."
sudo apt-get install -y -qq \
    jq \
    curl \
    wget \
    unzip \
    git \
    htop \
    tmux \
    tree \
    2>/dev/null
log "Utilities installed (jq, curl, git, htop, tmux, tree)"

# --- Step 12: Create workspace structure ---
WORKSPACE="$HOME/.openclaw/workspace"
if [ -d "$WORKSPACE" ]; then
    log "Workspace already exists: ${WORKSPACE}"
else
    info "Creating workspace structure..."
    mkdir -p "$WORKSPACE"/{memory,scripts,data,protocols}
    log "Workspace created at ${WORKSPACE}"
fi

# --- Summary ---
echo ""
echo "============================================"
echo "  ✅ Setup Complete!"
echo "============================================"
echo ""
echo "  Installed:"
echo "    • OpenClaw:      $(openclaw --version 2>/dev/null || echo 'check manually')"
echo "    • Node.js:       $(node --version 2>/dev/null)"
echo "    • npm:           $(npm --version 2>/dev/null)"
echo "    • gog (Google):  $(gog --version 2>/dev/null | head -1 || echo 'not installed')"
echo "    • Vercel:        $(vercel --version 2>/dev/null | head -1 || echo 'not installed')"
echo "    • Supabase:      $(npx supabase --version 2>/dev/null || echo 'not installed')"
echo "    • GitHub CLI:    $(gh --version 2>/dev/null | head -1 || echo 'not installed')"
echo "    • Claude Code:   $(claude --version 2>/dev/null | head -1 || echo 'installed')"
echo "    • Python:        $(python3 --version 2>/dev/null)"
echo "    • Salesforce:    $(sf --version 2>/dev/null | head -1 || echo 'not installed')"
echo ""
echo "  Next steps:"
echo "    1. Run: openclaw status"
echo "    2. Add AI provider: openclaw auth add anthropic"
echo "    3. Configure channels in ~/.openclaw/openclaw.json"
echo "    4. Connect WhatsApp: openclaw whatsapp link"
echo "    5. Customize: edit ~/.openclaw/workspace/SOUL.md"
echo ""
echo "  Docs: https://docs.openclaw.ai"
echo "  Support: https://discord.com/invite/clawd"
echo ""
