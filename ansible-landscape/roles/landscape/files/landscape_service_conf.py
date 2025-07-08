#!/usr/bin/python3
import configparser
import os
import base64
#from dotenv import load_dotenv # If you are using .env, otherwise remove

# Load environment variables from .env file (If you are using .env)
#load_dotenv()

# --- Configuration Variables ---
CONFIG_FILE_PATH = "/etc/landscape/service.conf"  # <<<<<<< VERIFY THIS PATH CAREFULLY
print(f"Attempting to read/write config at: {CONFIG_FILE_PATH}")

# Read sensitive information from environment variables (or from your secrets.py)
DB_LANDSCAPE_PASSWORD = os.getenv("DB_LANDSCAPE_PASSWORD")
RABBITMQ_PASSWORD = os.getenv("RABBITMQ_PASSWORD")
DB_SUPERUSER_NAME = os.getenv("DB_SUPERUSER_NAME")
DB_SUPERUSER_PASSWORD = os.getenv("DB_SUPERUSER_PASSWORD")

# Print the values we are about to use for debugging
print(f"DB_LANDSCAPE_PASSWORD (from env/secrets): [{DB_LANDSCAPE_PASSWORD}] (Type: {type(DB_LANDSCAPE_PASSWORD)})")
print(f"RABBITMQ_PASSWORD (from env/secrets): [{RABBITMQ_PASSWORD}] (Type: {type(RABBITMQ_PASSWORD)})")
print(f"DB_SUPERUSER_NAME (from env/secrets): [{DB_SUPERUSER_NAME}] (Type: {type(DB_SUPERUSER_NAME)})")
print(f"DB_SUPERUSER_PASSWORD (from env/secrets): [{DB_SUPERUSER_PASSWORD}] (Type: {type(DB_SUPERUSER_PASSWORD)})")

# Basic check to ensure variables are set
if not all([DB_LANDSCAPE_PASSWORD, RABBITMQ_PASSWORD, DB_SUPERUSER_NAME, DB_SUPERUSER_PASSWORD]):
    print("\nERROR: One or more required environment/secret variables are not set or are empty!")
    print("Please ensure DB_LANDSCAPE_PASSWORD, RABBITMQ_PASSWORD, DB_SUPERUSER_NAME, DB_SUPERUSER_PASSWORD are properly defined.")
    exit(1)

# Generate a random secret token
SECRET_TOKEN = base64.b64encode(os.urandom(96)).decode('utf-8').replace('\n', '')
print(f"Generated SECRET_TOKEN: [{SECRET_TOKEN[:20]}...{SECRET_TOKEN[-20:]}] (Length: {len(SECRET_TOKEN)})") # Print partial for security

# Create a ConfigParser object
config = configparser.ConfigParser(allow_no_value=False) # <<< Changed to False for stricter writing. If a key truly has no value, configparser might write it as 'key =' or 'key' depending on strictness. Let's see if False helps.
config.optionxform = str # Preserve case of options

# Read the existing configuration file
try:
    config.read(CONFIG_FILE_PATH)
    print(f"Sections found by configparser: {config.sections()}")
    # Debug existing password value
    if 'stores' in config and 'password' in config['stores']:
        print(f"Current password in [stores] before modification: [{config['stores']['password']}]")
except configparser.Error as e:
    print(f"Error reading config file: {e}")
    exit(1)

print("\n--- Applying Changes ---")

# Section [stores]
if 'stores' in config:
    # Update password for user landscape in [stores]
    print(f"Setting config['stores']['password'] to: [{DB_LANDSCAPE_PASSWORD}]")
    config['stores']['password'] = DB_LANDSCAPE_PASSWORD
else:
    print("Warning: [stores] section not found. Cannot update password.")

# Section [broker]
if 'broker' in config:
    print(f"Setting config['broker']['password'] to: [{RABBITMQ_PASSWORD}]")
    config['broker']['password'] = RABBITMQ_PASSWORD
else:
    print("Warning: [broker] section not found. Cannot update broker password.")

# Section [schema]
if 'schema' in config:
    print(f"Setting config['schema']['store_user'] to: [{DB_SUPERUSER_NAME}]")
    config['schema']['store_user'] = DB_SUPERUSER_NAME
    print(f"Setting config['schema']['store_password'] to: [{DB_SUPERUSER_PASSWORD}]")
    config['schema']['store_password'] = DB_SUPERUSER_PASSWORD
else:
    print("Warning: [schema] section not found. Cannot update schema credentials.")

# Section [landscape]
if 'landscape' in config:
    print(f"Setting config['landscape']['secret-token'] to: [{SECRET_TOKEN[:20]}...{SECRET_TOKEN[-20:]}]")
    config['landscape']['secret-token'] = SECRET_TOKEN
else:
    print("Warning: [landscape] section not found. Cannot add secret token.")

print("\n--- Writing Changes Back to File ---")
# Write the updated configuration back to the file
try:
    # Use a temporary file and then rename to ensure atomic write and prevent corruption
    temp_file_path = CONFIG_FILE_PATH + ".tmp"
    with open(temp_file_path, 'w') as configfile:
        config.write(configfile)
    os.replace(temp_file_path, CONFIG_FILE_PATH) # Atomically replace the original file
    print("Configuration update complete. File successfully written.")
except IOError as e:
    print(f"ERROR: Error writing to config file: {e}")
    exit(1)
except Exception as e:
    print(f"An unexpected error occurred during file write/replace: {e}")
    exit(1)
