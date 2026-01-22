#!/usr/bin/env bash
# Export all keys from system to git-crypt encrypted storage
# Run this to backup all your keys to the repo

set -e

echo "╔════════════════════════════════════════╗"
echo "║  Exporting Keys to Git-Crypt Storage   ║"
echo "╚════════════════════════════════════════╝"
echo ""

KEYS_DIR="$HOME/nixos-config/keys"

# Create directories
mkdir -p "$KEYS_DIR"/{ssh/machine,ssh/user,gpg,age}

# ============================================================================
# SSH Keys - User Level
# ============================================================================
echo "→ Exporting user SSH keys..."

if [ -d "$HOME/.ssh" ]; then
    # Find all private keys (files without .pub extension)
    for key in "$HOME/.ssh"/id_*; do
        if [ -f "$key" ] && [[ ! "$key" =~ \.pub$ ]]; then
            keyname=$(basename "$key")
            cp "$key" "$KEYS_DIR/ssh/user/$keyname"
            echo "  ✓ Copied $keyname"
            
            # Copy public key if it exists
            if [ -f "$key.pub" ]; then
                cp "$key.pub" "$KEYS_DIR/ssh/user/$keyname.pub"
                echo "  ✓ Copied $keyname.pub"
            fi
        fi
    done
else
    echo "  ⚠ No ~/.ssh directory found"
fi

# ============================================================================
# SSH Keys - Machine Level (if different location)
# ============================================================================
echo ""
echo "→ Exporting machine SSH keys..."

# Check common system SSH key locations
MACHINE_SSH_LOCATIONS=(
    "/etc/ssh"
    "/root/.ssh"
)

for location in "${MACHINE_SSH_LOCATIONS[@]}"; do
    if [ -d "$location" ] && [ -r "$location" ]; then
        for key in "$location"/ssh_host_*_key; do
            if [ -f "$key" ]; then
                keyname=$(basename "$key")
                sudo cp "$key" "$KEYS_DIR/ssh/machine/$keyname"
                sudo chown $USER:$USER "$KEYS_DIR/ssh/machine/$keyname"
                echo "  ✓ Copied $keyname (machine)"
                
                if [ -f "$key.pub" ]; then
                    sudo cp "$key.pub" "$KEYS_DIR/ssh/machine/$keyname.pub"
                    sudo chown $USER:$USER "$KEYS_DIR/ssh/machine/$keyname.pub"
                    echo "  ✓ Copied $keyname.pub (machine)"
                fi
            fi
        done
    fi
done

# ============================================================================
# GPG Keys
# ============================================================================
echo ""
echo "→ Exporting GPG keys..."

# Export developer GPG key (thephatle@proton.me)
if gpg --list-keys "thephatle@proton.me" &>/dev/null; then
    echo "  Exporting developer GPG key..."
    gpg --export --armor "thephatle@proton.me" > "$KEYS_DIR/gpg/developer-public.asc"
    gpg --export-secret-keys --armor "thephatle@proton.me" > "$KEYS_DIR/gpg/developer-private.asc"
    echo "  ✓ Exported developer GPG key (thephatle@proton.me)"
else
    echo "  ⚠ Developer GPG key not found"
fi

# Export secrets GPG key (jokinenmarko1@gmail.com)
if gpg --list-keys "jokinenmarko1@gmail.com" &>/dev/null; then
    echo "  Exporting secrets GPG key..."
    gpg --export --armor "jokinenmarko1@gmail.com" > "$KEYS_DIR/gpg/secrets-public.asc"
    gpg --export-secret-keys --armor "jokinenmarko1@gmail.com" > "$KEYS_DIR/gpg/secrets-private.asc"
    echo "  ✓ Exported secrets GPG key (jokinenmarko1@gmail.com)"
else
    echo "  ⚠ Secrets GPG key not found"
fi

# Export ALL GPG keys (backup)
echo "  Exporting all GPG keys (full backup)..."
gpg --export --armor > "$KEYS_DIR/gpg/all-public-keys.asc"
gpg --export-secret-keys --armor > "$KEYS_DIR/gpg/all-private-keys.asc"
echo "  ✓ Exported all GPG keys"

# ============================================================================
# Age Keys (Agenix)
# ============================================================================
echo ""
echo "→ Exporting age keys..."

if [ -f "$HOME/.config/age/keys.txt" ]; then
    cp "$HOME/.config/age/keys.txt" "$KEYS_DIR/age/keys.txt"
    echo "  ✓ Copied age keys.txt"
else
    echo "  ⚠ No age keys found at ~/.config/age/keys.txt"
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "╔════════════════════════════════════════╗"
echo "║  Key Export Complete!                  ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Keys exported to: $KEYS_DIR"
echo ""
echo "Next steps:"
echo "  1. cd ~/nixos-config"
echo "  2. git add keys/"
echo "  3. git commit -m \"Add encrypted key backup\""
echo "  4. Verify: git-crypt status | grep keys/"
echo ""
echo "⚠ IMPORTANT: These keys are encrypted with git-crypt."
echo "   Make sure you have your git-crypt key backed up!"
