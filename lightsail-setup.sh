# ============================================
# OpenClaw Lightsail Setup — Raw Commands
# Ubuntu (AWS Lightsail), tested March 2026
# Run in order. All commands need sudo.
# ============================================

# 1. System update (always first)
sudo apt update && sudo apt upgrade -y

# 2. Node.js 22 (skip if already installed)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# 3. OpenClaw (latest)
sudo npm install -g openclaw@latest

# 4. Google Workspace CLI (gog — Gmail, Calendar, Drive, Docs)
#    NOTE: Download to file first, then extract. Piping curl to tar fails on Lightsail.
cd /tmp
curl -Lo gog.tar.gz https://github.com/steipete/gogcli/releases/download/v0.11.0/gogcli_0.11.0_linux_amd64.tar.gz
sudo tar xzf gog.tar.gz -C /usr/local/bin
rm gog.tar.gz
gog --version

# 5. Supabase CLI (database management)
#    NOTE: npm global install is broken. Use the .deb package with exact version URL.
cd /tmp
curl -Lo supabase.deb https://github.com/supabase/cli/releases/download/v2.75.0/supabase_2.75.0_linux_amd64.deb
sudo dpkg -i supabase.deb
rm supabase.deb
supabase --version

# 6. Vercel (web app deployment)
sudo npm i -g vercel

# 7. GitHub CLI
#    NOTE: apt may not have it. Use GitHub's official repo.
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

# 8. Claude Code (AI coding agent)
sudo npm i -g @anthropic-ai/claude-code

# 9. Salesforce CLI
sudo npm i -g @salesforce/cli

# 10. Python tools
sudo apt install -y python3-pip python3-venv

# 11. Useful utilities
sudo apt install -y jq curl wget unzip git htop tmux tree

# ============================================
# Post-install: configure OpenClaw
# ============================================
# openclaw status
# openclaw auth add anthropic
# nano ~/.openclaw/openclaw.json
# openclaw whatsapp link
