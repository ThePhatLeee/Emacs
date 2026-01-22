#!/usr/bin/env bash
# Complete system restore from git-crypt backup
# Run this on a fresh NixOS install

set -e

echo "╔════════════════════════════════════════╗"
echo "║  Full System Key Restore               ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Check if we're in the repo
if [ ! -f "$HOME/nixos-config/.gitattributes" ]; then
    echo "❌ Error: Not in nixos-config directory"
    echo ""
    echo "First steps on new machine:"
    echo "  1. Clone repo: git clone <your-repo-url> ~/nixos-config"
    echo "  2. cd ~/nixos-config"
    echo "  3. Unlock git-crypt: git-crypt unlock /path/to/git-crypt-key"
    echo "  4. Then run this script"
    exit 1
fi

# Check if git-crypt is unlocked
if git-crypt status | grep -q "encrypted"; then
    echo "❌ Error: Git-crypt is not unlocked!"
    echo ""
    echo "Unlock with: git-crypt unlock /path/to/git-crypt-key"
    exit 1
fi

echo "✓ Git-crypt is unlocked"
echo ""

# Import keys
echo "Importing all keys..."
"$HOME/nixos-config/scripts/import-keys.sh"

# Initialize pass with secrets GPG key
echo ""
echo "→ Initializing password store..."
if [ -d "$HOME/.password-store" ]; then
    echo "  ⚠ Password store already exists, skipping"
else
    pass init "jokinenmarko1@gmail.com"
    echo "  ✓ Password store initialized"
fi

# Generate authinfo
echo ""
echo "→ Generating .authinfo.gpg..."
"$HOME/nixos-config/scripts/create-authinfo.sh"

echo ""
echo "╔════════════════════════════════════════╗"
echo "║  System Restore Complete!              ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. sudo nixos-rebuild switch"
echo "  2. doom sync"
echo "  3. Restart Emacs"
echo ""
echo "Your system is ready! 🚀"
