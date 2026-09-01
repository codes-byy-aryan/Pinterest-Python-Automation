#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# setup.sh — One-time setup for Pinterest Automation on Oracle Cloud VM
# Run as: bash setup.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON=python3

echo "════════════════════════════════════════════"
echo "  Pinterest Automation — Setup Script"
echo "════════════════════════════════════════════"

# ── 1. System packages ────────────────────────────────────────────────────────
echo ""
echo "📦 Installing system packages..."
sudo apt-get update -y
sudo apt-get install -y python3 python3-pip python3-venv curl

# ── 2. Python virtual environment ────────────────────────────────────────────
echo ""
echo "🐍 Creating Python virtual environment..."
cd "$SCRIPT_DIR"
$PYTHON -m venv venv
source venv/bin/activate

# ── 3. Python dependencies ────────────────────────────────────────────────────
echo ""
echo "📚 Installing Python packages..."
pip install --upgrade pip
pip install -r requirements.txt

# ── 4. .env file ──────────────────────────────────────────────────────────────
echo ""
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
    echo "⚙️  Created .env from template."
    echo "   👉 EDIT IT NOW:  nano $SCRIPT_DIR/.env"
else
    echo "✅ .env already exists — skipping."
fi

# ── 5. Make scripts executable ────────────────────────────────────────────────
chmod +x "$SCRIPT_DIR/main.py"
chmod +x "$SCRIPT_DIR/setup.sh"

# ── 6. Cron job (10:00 AM daily IST = 04:30 UTC) ──────────────────────────────
echo ""
echo "⏰ Setting up cron job (10:00 AM IST daily)..."

CRON_LOG="$SCRIPT_DIR/cron.log"
CRON_CMD="30 4 * * * cd $SCRIPT_DIR && $SCRIPT_DIR/venv/bin/python $SCRIPT_DIR/main.py >> $CRON_LOG 2>&1"

# Add only if not already present
( crontab -l 2>/dev/null | grep -v "pinterest_automation"; echo "$CRON_CMD" ) | crontab -

echo ""
echo "════════════════════════════════════════════"
echo "  ✅  Setup Complete!"
echo "════════════════════════════════════════════"
echo ""
echo "  Next steps:"
echo "  1. Fill in your API keys:"
echo "     nano $SCRIPT_DIR/.env"
echo ""
echo "  2. Test the script manually:"
echo "     cd $SCRIPT_DIR && source venv/bin/activate && python main.py"
echo ""
echo "  3. Verify cron job:"
echo "     crontab -l"
echo ""
echo "  4. Monitor logs:"
echo "     tail -f $SCRIPT_DIR/automation.log"
echo "════════════════════════════════════════════"
