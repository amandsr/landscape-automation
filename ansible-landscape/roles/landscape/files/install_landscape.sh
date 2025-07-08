#!/bin/bash

# --- Define your variables securely (e.g., from environment variables) ---
# It's best practice to pass these as environment variables or read from a secure secret store.
# For example, to run this:
# export LANDSCAPE_FQDN="your_landscape_fqdn.com"
# export SMTP_SERVER="smtp.yourprovider.com"
# export SMTP_PORT="587"
# export SMTP_USERNAME="your_smtp_username"
# export SMTP_PASSWORD="YOUR_ACTUAL_SMTP_PASSWORD"
# export SYSTEM_EMAIL="landscape@your_landscape_fqdn.com"
# ./install_landscape_with_smtp.sh

# Default values if environment variables are not set (for testing, but prefer env vars)
LANDSCAPE_FQDN="${LANDSCAPE_FQDN:-landscape.example.com}"
SMTP_SERVER="${SMTP_SERVER:-smtp.sendgrid.net}"
SMTP_PORT="${SMTP_PORT:-587}"
SMTP_USERNAME="${SMTP_USERNAME:-apikey}"
SMTP_PASSWORD="${SMTP_PASSWORD:-YOUR_ACTUAL_SMTP_PASSWORD}" # !!! SERIOUSLY, USE ENV VARS OR A SECURE METHOD FOR THIS !!!
SYSTEM_EMAIL="${SYSTEM_EMAIL:-landscape@example.com}"

echo "Preparing debconf selections for Postfix and Landscape Server..."

# Create the debconf seed file dynamically in /tmp
# Using a temp file is safer and cleaner than echoing directly to debconf-set-selections
cat << EOF > /tmp/landscape_install_debconf.seed
# Postfix configuration based on debconf-show output
postfix postfix/main_mailer_type select Internet Site
postfix postfix/mailname string $LANDSCAPE_FQDN
postfix postfix/destinations string $LANDSCAPE_FQDN, localhost.localdomain, localhost
postfix postfix/relayhost string $SMTP_SERVER:$SMTP_PORT
postfix postfix/root_address string root@$LANDSCAPE_FQDN # Direct root mail to FQDN

# Landscape Server SMTP Configuration (These are specific to Landscape, not Postfix)
# Ensure these template names are correct for your landscape-server package
# You might need to verify these with 'debconf-show landscape-server'
landscape-server landscape-server/smtp-server string $SMTP_SERVER
landscape-server landscape-server/smtp-port string $SMTP_PORT
landscape-server landscape-server/smtp-username string $SMTP_USERNAME
landscape-server landscape-server/smtp-password password $SMTP_PASSWORD
landscape-server landscape-server/smtp-use-tls boolean true
landscape-server landscape-server/system-email-address string $SYSTEM_EMAIL
landscape-server landscape-server/use-system-email boolean false # Set to false to use custom SMTP
EOF

echo "Applying debconf selections..."
sudo debconf-set-selections /tmp/landscape_install_debconf.seed

echo "Updating apt package lists..."
sudo apt-get update

echo "Installing Landscape Server (and Postfix if not already configured)..."
# Use DEBIAN_FRONTEND=noninteractive to prevent interactive prompts
# Install landscape-server. If Postfix is not fully configured, this will
# trigger its configuration using the pre-seeded values.
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y landscape-server

# You may need to install other Landscape components as well, depending on your setup
# Example: sudo DEBIAN_FRONTEND=noninteractive apt-get install -y landscape-client landscape-proxy

echo "Cleaning up temporary debconf seed file..."
rm /tmp/landscape_install_debconf.seed

echo "Landscape Server installation process completed."

# Important: After installation, you might need to restart services or perform
# additional Landscape specific setup steps, like generating client certificates
# or configuring the web server.
