#!/bin/bash

RABBITMQ_ENV_CONF="/etc/rabbitmq/rabbitmq-env.conf"

echo "Backing up ${RABBITMQ_ENV_CONF} to ${RABBITMQ_ENV_CONF}.bak"
sudo cp "$RABBITMQ_ENV_CONF" "${RABBITMQ_ENV_CONF}.bak"

echo "Uncommenting NODE_IP_ADDRESS in ${RABBITMQ_ENV_CONF}..."
# This sed command looks for a line starting with '#NODE_IP_ADDRESS='
# and removes the '#' character at the beginning of that line.
sudo sed -i 's/^#NODE_IP_ADDRESS=/NODE_IP_ADDRESS=/' "$RABBITMQ_ENV_CONF"

echo "Configuration change applied. Verifying changes..."

# Verify the change
grep "NODE_IP_ADDRESS" "$RABBITMQ_ENV_CONF"

echo ""
echo "IMPORTANT: RabbitMQ service restart is required for these changes to take effect."
echo "You can restart it using: sudo systemctl restart rabbitmq-server"
