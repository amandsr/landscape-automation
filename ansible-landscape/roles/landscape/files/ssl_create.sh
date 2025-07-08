#!/bin/bash

# === Parse Arguments ===
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -c) COUNTRY="$2"; shift ;;
    -s) STATE="$2"; shift ;;
    -l) LOCALITY="$2"; shift ;;
    -o) ORG="$2"; shift ;;
    -u) UNIT="$2"; shift ;;
    -n) CN="$2"; shift ;;
    -a) ALT_NAMES="$2"; shift ;;
    -d) DAYS="$2"; shift ;;
    -k) KEY_FILE="$2"; shift ;;
    -t) CRT_FILE="$2"; shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# === Validation ===
if [[ -z "$COUNTRY" || -z "$STATE" || -z "$LOCALITY" || -z "$ORG" || -z "$UNIT" || -z "$CN" || -z "$ALT_NAMES" || -z "$DAYS" || -z "$KEY_FILE" || -z "$CRT_FILE" ]]; then
  echo "Missing required arguments."
  exit 1
fi

# === Create OpenSSL Config ===
CONFIG_FILE="openssl.conf"
cat > "$CONFIG_FILE" <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
C=$COUNTRY
ST=$STATE
L=$LOCALITY
O=$ORG
OU=$UNIT
CN=$CN

[ req_ext ]
subjectAltName = $ALT_NAMES
EOF

# === Generate Private Key and Certificate ===
openssl req -x509 -nodes -days "$DAYS" -newkey rsa:2048 \
  -keyout "$KEY_FILE" \
  -out "$CRT_FILE" \
  -config "$CONFIG_FILE"

echo "✅ SSL certificate generated: $CRT_FILE"
echo "✅ Private key generated: $KEY_FILE"

