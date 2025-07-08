#!/bin/bash

POSTGRES_CONF="/etc/postgresql/16/main/postgresql.conf"

echo "Backing up ${POSTGRES_CONF} to ${POSTGRES_CONF}.bak"
sudo cp "$POSTGRES_CONF" "${POSTGRES_CONF}.bak"

echo "Updating max_connections to 400..."
# This command looks for a line starting with 'max_connections =' and replaces the entire line
sudo sed -i 's/^max_connections = .*/max_connections = 400/' "$POSTGRES_CONF"

echo "Updating max_prepared_transactions to 400..."
# This command looks for a line starting with '#max_prepared_transactions ='
# and replaces it, effectively uncommenting and setting the value.
sudo sed -i 's/^#max_prepared_transactions = .*/max_prepared_transactions = 400/' "$POSTGRES_CONF"

echo "Configuration changes applied. Verifying changes..."

# Verify the changes
echo "--- Current max_connections setting ---"
grep "max_connections" "$POSTGRES_CONF"

echo "--- Current max_prepared_transactions setting ---"
grep "max_prepared_transactions" "$POSTGRES_CONF"

echo ""
echo "IMPORTANT: PostgreSQL service restart is required for these changes to take effect."
echo "You can restart it using: sudo systemctl restart postgresql@16-main"
