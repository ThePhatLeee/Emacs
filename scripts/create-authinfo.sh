#!/usr/bin/env bash
# Create ~/.authinfo.gpg from pass secrets

set -e

echo "Creating authinfo from pass secrets..."

# Get secrets from pass
IRC_SERVER=$(pass show irc/server)
IRC_NICK=$(pass show irc/nick)
IRC_PASSWORD=$(pass show irc/password)
LOGIN_EMAIL=$(pass show personal/email)
GPG_EMAIL=$(pass show developer/email)
# Optional: Email credentials
if pass show email/smtp-password &>/dev/null; then
    SMTP_SERVER=$(pass show email/smtp-server)
    SMTP_PASSWORD=$(pass show email/smtp-password)
    IMAP_SERVER=$(pass show email/imap-server)
    IMAP_PASSWORD=$(pass show email/imap-password)
    HAS_EMAIL=true
else
    HAS_EMAIL=false
fi

# Create authinfo
cat > ~/.authinfo << EOF
# IRC
machine $IRC_SERVER login $IRC_NICK port 6697 password $IRC_PASSWORD
EOF

if [ "$HAS_EMAIL" = true ]; then
    cat >> ~/.authinfo << EOF

# Email SMTP
machine $SMTP_SERVER login $EMAIL port 587 password $SMTP_PASSWORD

# Email IMAP
machine $IMAP_SERVER login $EMAIL port 993 password $IMAP_PASSWORD
EOF
fi

# Encrypt with GPG
echo "Encrypting for GPG identity: $GPG_EMAIL..."
gpg --encrypt --recipient "$GPG_EMAIL" ~/.authinfo
# Remove plaintext
rm ~/.authinfo

# Set permissions
chmod 600 ~/.authinfo.gpg

echo "✓ Created ~/.authinfo.gpg"
echo "✓ IRC credentials: $IRC_NICK@$IRC_SERVER"
if [ "$HAS_EMAIL" = true ]; then
    echo "✓ Email credentials: $EMAIL"
fi
