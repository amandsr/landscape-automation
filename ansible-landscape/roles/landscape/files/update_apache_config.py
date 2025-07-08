#!/usr/bin/python3
import re
import os
import shutil # For file operations like copying/moving

# --- Configuration ---
# 1. Input file path
input_file = "/etc/apache2/sites-available/landscape.conf" # Your Apache config file

# 2. Environment variable name for hostname
HOSTNAME_ENV_VAR = "LANDSCAPE_HOSTNAME"

# 3. Get the hostname from environment variable
# Fallback to a default if the environment variable is not set.
# It's highly recommended to set this environment variable before running the script.
hostname = os.getenv(HOSTNAME_ENV_VAR, "default-landscape-server") # Use a meaningful default

if hostname == "default-landscape-server":
    print(f"Warning: Environment variable '{HOSTNAME_ENV_VAR}' not set. Using default hostname: '{hostname}'")
else:
    print(f"Using hostname from environment variable '{HOSTNAME_ENV_VAR}': '{hostname}'")

# --- Backup the original file ---
backup_file = f"{input_file}.bak"
try:
    shutil.copy2(input_file, backup_file) # copy2 preserves metadata
    print(f"Original file backed up to: {backup_file}")
except FileNotFoundError:
    print(f"Error: Input file '{input_file}' not found. Cannot proceed with backup or modification.")
    exit(1)
except Exception as e:
    print(f"Error backing up file: {e}")
    exit(1)

# --- Read the input file ---
try:
    with open(input_file, "r") as file:
        content = file.read()
except IOError as e:
    print(f"Error reading input file '{input_file}': {e}")
    exit(1)

# --- Perform replacements ---
print("Performing replacements...")

# 1. Replace all SSLCertificate*File lines to point to the new paths with the hostname
# This is a bit tricky because you have multiple lines to override and some might be commented.
# We'll use specific regex patterns for each type of line to target them precisely.

# Pattern 1: SSLCertificateFile lines (including those with @certfile@ or ${ssl_certificate_crt})
# This will match lines like:
# SSLCertificateFile @certfile@
# SSLCertificateFile ${ssl_certificate_crt}
# And replace them with the desired path.
content = re.sub(
    r"SSLCertificateFile\s+(?:@certfile@|\$\{[a-zA-Z0-9_]+\}|\S+)",
    f"SSLCertificateFile /etc/ssl/certs/{hostname}.crt",
    content
)

# Pattern 2: SSLCertificateKeyFile lines (including those with @keyfile@ or ${ssl_certificate_key})
# This will match lines like:
# SSLCertificateKeyFile @keyfile@
# SSLCertificateKeyFile ${ssl_certificate_key}
content = re.sub(
    r"SSLCertificateKeyFile\s+(?:@keyfile@|\$\{[a-zA-Z0-9_]+\}|\S+)",
    f"SSLCertificateKeyFile /etc/ssl/certs/{hostname}.key",
    content
)

# Pattern 3: SSLCertificateChainFile lines (handling commented and uncommented)
# This will match lines like:
# # SSLCertificateChainFile /etc/ssl/certs/landscape_server_ca.crt
# (and if it were uncommented like: SSLCertificateChainFile some_path)
# The key is to include the '#' and optional whitespace in the pattern if present.
content = re.sub(
    r"#?\s*SSLCertificateChainFile\s+.*",
    f"SSLCertificateChainFile /etc/ssl/certs/{hostname}.crt",
    content
)


# 2. Replace hostname placeholders (@hostname@ and ${hostname})
content = content.replace("@hostname@", hostname)
content = content.replace("${hostname}", hostname)


# --- Write the modified content back to the original file (atomically) ---
# Use a temporary file and then rename to ensure atomic write and prevent corruption
temp_file_path = f"{input_file}.tmp"
try:
    with open(temp_file_path, "w") as file:
        file.write(content)
    os.replace(temp_file_path, input_file) # Atomically replace the original file
    print(f"Modifications complete. Original file '{input_file}' updated.")
except IOError as e:
    print(f"Error writing to output file '{input_file}': {e}")
except Exception as e:
    print(f"An unexpected error occurred during file write/replace: {e}")

