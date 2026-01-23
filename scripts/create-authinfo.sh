#!/usr/bin/env bash
# Create ~/.authinfo.gpg from pass secrets
# Matches your actual pass structure

set -e

echo "╔════════════════════════════════════════╗"
echo "║   Generating .authinfo.gpg from pass   ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Get primary email for GPG encryption
# FIX: Added head -n 1 to prevent newline/metadata corruption
PRIMARY_EMAIL=$(pass show email/gmail-personal/address 2>/dev/null | head -n 1 || echo "")

if [ -z "$PRIMARY_EMAIL" ]; then
    echo "❌ Error: Primary email not found"
    exit 1
fi

# Create authinfo header
cat > ~/.authinfo << EOF
# Auto-generated from pass - DO NOT EDIT MANUALLY
# Run: ~/nixos-config/scripts/create-authinfo.sh
# Generated: $(date)
# Primary: $PRIMARY_EMAIL
EOF

# ============================================================================
# IRC - Libera Chat
# ============================================================================
IRC_SERVER=$(pass show services/irc/server 2>/dev/null | head -n 1 || echo "")
IRC_NICK=$(pass show services/irc/nick 2>/dev/null | head -n 1 || echo "")
IRC_PASSWORD=$(pass show services/irc/password 2>/dev/null | head -n 1 || echo "")

if [ -n "$IRC_SERVER" ] && [ -n "$IRC_NICK" ] && [ -n "$IRC_PASSWORD" ]; then
    # FIX: Added quotes around variables
    cat >> ~/.authinfo << EOF

# ============================================================================
# IRC - Libera Chat
# ============================================================================
machine "$IRC_SERVER" login "$IRC_NICK" port 6697 password "$IRC_PASSWORD"
EOF
    echo "✓ IRC: $IRC_NICK@$IRC_SERVER"
fi

# ============================================================================
# Matrix
# ============================================================================
MATRIX_HOMESERVER=$(pass show services/matrix/homeserver 2>/dev/null | head -n 1 || echo "")
MATRIX_USERNAME=$(pass show services/matrix/username 2>/dev/null | head -n 1 || echo "")
MATRIX_TOKEN=$(pass show services/matrix/token 2>/dev/null | head -n 1 || echo "")

if [ -n "$MATRIX_HOMESERVER" ] && [ -n "$MATRIX_TOKEN" ] && [ -n "$MATRIX_USERNAME" ]; then
    MATRIX_HOST=$(echo "$MATRIX_HOMESERVER" | sed -E 's|https?://||' | sed 's|/.*||')
    
    # FIX: Added quotes, especially important for the complex login string
    cat >> ~/.authinfo << EOF

# ============================================================================
# Matrix - $MATRIX_HOMESERVER
# ============================================================================
machine "$MATRIX_HOST" login "@$MATRIX_USERNAME:$MATRIX_HOST" port 443 password "$MATRIX_TOKEN"
EOF
    echo "✓ Matrix: @$MATRIX_USERNAME:$MATRIX_HOST"
fi

# ============================================================================
# Email 1: Gmail Personal
# ============================================================================
GMAIL_ADDRESS=$(pass show email/gmail-personal/address 2>/dev/null | head -n 1 || echo "")
GMAIL_PASSWORD=$(pass show email/mail-personal/app-password 2>/dev/null | head -n 1 || \
                 pass show email/gmail-personal/app-password 2>/dev/null | head -n 1 || echo "")

if [ -n "$GMAIL_ADDRESS" ] && [ -n "$GMAIL_PASSWORD" ]; then
    cat >> ~/.authinfo << EOF

# ============================================================================
# Email 1: Gmail Personal ($GMAIL_ADDRESS)
# ============================================================================
# SMTP
machine smtp.gmail.com login "$GMAIL_ADDRESS" port 587 password "$GMAIL_PASSWORD"
# IMAP
machine imap.gmail.com login "$GMAIL_ADDRESS" port 993 password "$GMAIL_PASSWORD"
EOF
    echo "✓ Gmail Personal: $GMAIL_ADDRESS"
fi

# ============================================================================
# Email 2: Proton Personal (Bridge)
# ============================================================================
PROTON_PERSONAL_ADDRESS=$(pass show email/proton-personal/address 2>/dev/null | head -n 1 || echo "")
PROTON_PERSONAL_PASSWORD=$(pass show email/proton-personal/bridge-password 2>/dev/null | head -n 1 || echo "")

if [ -n "$PROTON_PERSONAL_ADDRESS" ] && [ -n "$PROTON_PERSONAL_PASSWORD" ]; then
    cat >> ~/.authinfo << EOF

# ============================================================================
# Email 2: Proton Personal via Bridge ($PROTON_PERSONAL_ADDRESS)
# ============================================================================
# SMTP (Proton Bridge)
machine 127.0.0.1 login "$PROTON_PERSONAL_ADDRESS" port 1025 password "$PROTON_PERSONAL_PASSWORD"
# IMAP (Proton Bridge)
machine 127.0.0.1 login "$PROTON_PERSONAL_ADDRESS" port 1143 password "$PROTON_PERSONAL_PASSWORD"
EOF
    echo "✓ Proton Personal (Bridge): $PROTON_PERSONAL_ADDRESS"
fi

# ============================================================================
# Email 3: Proton PM Alias
# ============================================================================
PROTON_PM_ADDRESS=$(pass show email/proton-pm-alias/address 2>/dev/null | head -n 1 || echo "")
PROTON_PM_PASSWORD=$(pass show email/proton-pm-alias/bridge-password 2>/dev/null | head -n 1 || echo "")

if [ -n "$PROTON_PM_ADDRESS" ] && [ -n "$PROTON_PM_PASSWORD" ]; then
    cat >> ~/.authinfo << EOF

# ============================================================================
# Email 3: Proton PM Alias via Bridge ($PROTON_PM_ADDRESS)
# ============================================================================
# SMTP (Proton Bridge)
machine 127.0.0.1 login "$PROTON_PM_ADDRESS" port 1025 password "$PROTON_PM_PASSWORD"
# IMAP (Proton Bridge)
machine 127.0.0.1 login "$PROTON_PM_ADDRESS" port 1143 password "$PROTON_PM_PASSWORD"
EOF
    echo "✓ Proton PM Alias (Bridge): $PROTON_PM_ADDRESS"
fi

# ============================================================================
# Email 4: Proton Developer
# ============================================================================
PROTON_DEV_ADDRESS=$(pass show email/proton-developer/address 2>/dev/null | head -n 1 || echo "")
PROTON_DEV_PASSWORD=$(pass show email/proton-developer/bridge-password 2>/dev/null | head -n 1 || echo "")

if [ -n "$PROTON_DEV_ADDRESS" ] && [ -n "$PROTON_DEV_PASSWORD" ]; then
    cat >> ~/.authinfo << EOF

# ============================================================================
# Email 4: Proton Developer via Bridge ($PROTON_DEV_ADDRESS)
# ============================================================================
# SMTP (Proton Bridge)
machine 127.0.0.1 login "$PROTON_DEV_ADDRESS" port 1025 password "$PROTON_DEV_PASSWORD"
# IMAP (Proton Bridge)
machine 127.0.0.1 login "$PROTON_DEV_ADDRESS" port 1143 password "$PROTON_DEV_PASSWORD"
EOF
    echo "✓ Proton Developer (Bridge): $PROTON_DEV_ADDRESS"
fi

# ============================================================================
# Email 5: Company
# ============================================================================
COMPANY_ADDRESS=$(pass show email/company/address 2>/dev/null | head -n 1 || echo "")
COMPANY_PASSWORD=$(pass show email/company/bridge-password 2>/dev/null | head -n 1 || echo "")

if [ -n "$COMPANY_ADDRESS" ] && [ -n "$COMPANY_PASSWORD" ]; then
    cat >> ~/.authinfo << EOF

# ============================================================================
# Email 5: Company via Proton Bridge ($COMPANY_ADDRESS)
# ============================================================================
# SMTP (Proton Bridge)
machine 127.0.0.1 login "$COMPANY_ADDRESS" port 1025 password "$COMPANY_PASSWORD"
# IMAP (Proton Bridge)
machine 127.0.0.1 login "$COMPANY_ADDRESS" port 1143 password "$COMPANY_PASSWORD"
EOF
    echo "✓ Company (Bridge): $COMPANY_ADDRESS"
fi

# ============================================================================
# Email 6: Work NW Group
# ============================================================================
WORK_ADDRESS=$(pass show email/work-nwgroup/address 2>/dev/null | head -n 1 || echo "")
WORK_PASSWORD=$(pass show email/work-nwgroup/password 2>/dev/null | head -n 1 || echo "")
WORK_SMTP=$(pass show email/work-nwgroup/smtp-server 2>/dev/null | head -n 1 || echo "")
WORK_IMAP=$(pass show email/work-nwgroup/imap-server 2>/dev/null | head -n 1 || echo "")

if [ -n "$WORK_ADDRESS" ] && [ -n "$WORK_PASSWORD" ]; then
    cat >> ~/.authinfo << EOF

# ============================================================================
# Email 6: Work NW Group ($WORK_ADDRESS)
# ============================================================================
EOF
    if [ -n "$WORK_SMTP" ]; then
        echo "machine \"$WORK_SMTP\" login \"$WORK_ADDRESS\" port 587 password \"$WORK_PASSWORD\"" >> ~/.authinfo
    fi
    if [ -n "$WORK_IMAP" ]; then
        echo "machine \"$WORK_IMAP\" login \"$WORK_ADDRESS\" port 993 password \"$WORK_PASSWORD\"" >> ~/.authinfo
    fi
    echo "✓ Work NW Group: $WORK_ADDRESS"
fi

# ============================================================================
# Encrypt with GPG
# ============================================================================
echo ""
echo "Encrypting with GPG for: $PRIMARY_EMAIL"

if gpg --list-keys "$PRIMARY_EMAIL" &>/dev/null; then
    # We encrypt using the new email identity
    gpg --batch --yes --encrypt --recipient "$PRIMARY_EMAIL" -o ~/.authinfo.gpg ~/.authinfo
    rm ~/.authinfo
    chmod 600 ~/.authinfo.gpg
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║   ✓ Success! .authinfo.gpg generated   ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "Accounts configured:"
    echo "  • IRC: Libera Chat"
    echo "  • Matrix: $MATRIX_HOST"
    echo "  • 6 Email accounts"
    echo ""
    echo "Restart Emacs or: M-x auth-source-forget-all-cached"
else
    echo "❌ Error: GPG key not found for $PRIMARY_EMAIL"
    rm ~/.authinfo
    exit 1
fi
