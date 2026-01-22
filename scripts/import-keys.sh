#!/usr/bin/env bash
# Import all keys from git-crypt encrypted storage to system
# Run this on a new machine after git-crypt unlock

set -e

echo "╔════════════════════════════════════════╗"
echo "║  Importing Keys from Git-Crypt Storage ║"
echo "╚════════════════════════════════════════╝"
echo ""

KEYS_DIR="$HOME/nixos-config/keys"

if [ ! -d "$KEYS_DIR" ]; then
    echo "❌ Error: Keys directory not found: $KEYS_DIR"
    echo ""
    echo "Make sure you've:"
    echo "  1. Cloned the repo: git clone <repo>"
    echo "  2. Unlocked git-crypt: cd nixos-config && git-crypt unlock"
    exit 1
fi

# ============================================================================
# SSH Keys - User Level
# ============================================================================
echo "→ Importing user SSH keys..."

if [ -d "$KEYS_DIR/ssh/user" ]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Copy all keys
    for key in "$KEYS_DIR/ssh/user"/*; do
        if [ -f "$key" ]; then
            keyname=$(basename "$key")
            cp "$key" "$HOME/.ssh/$keyname"
            
            # Set correct permissions
            if [[ "$keyname" =~ \.pub$ ]]; then
                chmod 644 "$HOME/.ssh/$keyname"
                echo "  ✓ Imported $keyname (public)"
            else
                chmod 600 "$HOME/.ssh/$keyname"
                echo "  ✓ Imported $keyname (private)"
            fi
        fi
    done
else
    echo "  ⚠ No user SSH keys found"
fi

# ============================================================================
# SSH Keys - Machine Level (requires root)
# ============================================================================
echo ""
echo "→ Importing machine SSH keys..."

if [ -d "$KEYS_DIR/ssh/machine" ]; then
    if [ "$EUID" -eq 0 ]; then
        # Running as root
        for key in "$KEYS_DIR/ssh/machine"/*; do
            if [ -f "$key" ]; then
                keyname=$(basename "$key")
                cp "$key" "/etc/ssh/$keyname"
                
                if [[ "$keyname" =~ \.pub$ ]]; then
                    chmod 644 "/etc/ssh/$keyname"
                else
                    chmod 600 "/etc/ssh/$keyname"
                fi
                echo "  ✓ Imported $keyname (machine)"
            fi
        done
    else
        echo "  ⚠ Skipping machine keys (requires root)"
        echo "    Run with sudo to import machine keys"
    fi
else
    echo "  ⚠ No machine SSH keys found"
fi

# ============================================================================
# GPG Keys
# ============================================================================
echo ""
echo "→ Importing GPG keys..."

if [ -d "$KEYS_DIR/gpg" ]; then
    # Import developer key
    if [ -f "$KEYS_DIR/gpg/developer-public.asc" ]; then
        gpg --import "$KEYS_DIR/gpg/developer-public.asc" 2>/dev/null
        echo "  ✓ Imported developer public key"
    fi
    
    if [ -f "$KEYS_DIR/gpg/developer-private.asc" ]; then
        gpg --import "$KEYS_DIR/gpg/developer-private.asc" 2>/dev/null
        echo "  ✓ Imported developer private key"
    fi
    
    # Import secrets key
    if [ -f "$KEYS_DIR/gpg/secrets-public.asc" ]; then
        gpg --import "$KEYS_DIR/gpg/secrets-public.asc" 2>/dev/null
        echo "  ✓ Imported secrets public key"
    fi
    
    if [ -f "$KEYS_DIR/gpg/secrets-private.asc" ]; then
        gpg --import "$KEYS_DIR/gpg/secrets-private.asc" 2>/dev/null
        echo "  ✓ Imported secrets private key"
    fi
    
    # Trust the keys ultimately
    echo ""
    echo "  Setting trust level to ultimate..."
    
    # Get key IDs and set trust
    for email in "thephatle@proton.me" "jokinenmarko1@gmail.com"; do
        KEY_ID=$(gpg --list-keys --with-colons "$email" 2>/dev/null | awk -F: '/^pub/{print $5}' | head -1)
        if [ -n "$KEY_ID" ]; then
            echo "$KEY_ID:6:" | gpg --import-ownertrust 2>/dev/null
            echo "  ✓ Set ultimate trust for $email"
        fi
    done
else
    echo "  ⚠ No GPG keys found"
fi

# ============================================================================
# Age Keys (Agenix)
# ============================================================================
echo ""
echo "→ Importing age keys..."

if [ -f "$KEYS_DIR/age/keys.txt" ]; then
    mkdir -p "$HOME/.config/age"
    cp "$KEYS_DIR/age/keys.txt" "$HOME/.config/age/keys.txt"
    chmod 600 "$HOME/.config/age/keys.txt"
    echo "  ✓ Imported age keys"
else
    echo "  ⚠ No age keys found"
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "╔════════════════════════════════════════╗"
echo "║  Key Import Complete!                  ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Imported:"
echo "  • SSH keys → ~/.ssh/"
echo "  • GPG keys → GPG keyring"
echo "  • Age keys → ~/.config/age/"
echo ""
echo "Verify GPG keys: gpg --list-keys"
echo "Verify SSH keys: ls -la ~/.ssh/"
echo "Verify age keys: cat ~/.config/age/keys.txt"
