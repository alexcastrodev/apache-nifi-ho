#!/bin/bash

# =================================================================
# THIS IS JUST FOR TESTING PURPOSES, DO NOT USE IN PRODUCTION
KEYSTORE_PASSWORD="QKZv1hSWAFQYZ+WU1jjF5ank+l4igeOfQRp+OSbkkrs"
TRUSTSTORE_PASSWORD="rHkWR1gDNW3R9hgbeRsT3OM3Ue0zwGtQqcFKJD2EXWE"
# =================================================================

# --- Configuration ---
CERT_DIR="./certs/localhost"
COMMON_NAME="localhost"
ORGANIZATIONAL_UNIT="NiFi"
ORGANIZATION="Apache"
LOCALITY="Lisbon"
STATE_PROVINCE="Lisbon"
COUNTRY_CODE="PT"
CERT_VALIDITY_DAYS=3650 # 10 years

CERT_ALIAS="nifi"
TRUST_ALIAS="nifi_trust"

# --- Function to check if keytool is available ---
check_keytool() {
    if ! command -v keytool &> /dev/null
    then
        echo "Error: 'keytool' not found. Please ensure JDK is installed and in your system's PATH."
        echo "Exiting."
        exit 1
    fi
}

# --- Main script execution ---
check_keytool

echo "--- Starting NiFi certificate generation ---"

# --- 1. Create certificate directory if it doesn't exist ---
echo "Creating certificate directory: $CERT_DIR"
mkdir -p "$CERT_DIR"
if [ $? -ne 0 ]; then
    echo "Error: Could not create directory $CERT_DIR. Check permissions."
    exit 1
fi

# Change to the certificate directory for keytool operations
cd "$CERT_DIR" || { echo "Error: Could not change to directory $CERT_DIR"; exit 1; }

# --- 2. Remove old certificates to ensure a clean start ---
echo "Removing existing certificates and keystores in $CERT_DIR..."
rm -f keystore.jks truststore.jks nifi_cert.cer

# --- 3. Generate Keystore and Self-Signed Certificate for NiFi ---
echo "Generating keystore.jks and self-signed certificate for NiFi..."
keytool -genkeypair -alias "$CERT_ALIAS" -keyalg RSA -keysize 2048 -storetype JKS \
-keystore keystore.jks \
-storepass "$KEYSTORE_PASSWORD" \
-keypass "$KEYSTORE_PASSWORD" \
-dname "CN=${COMMON_NAME}, OU=${ORGANIZATIONAL_UNIT}, O=${ORGANIZATION}, L=${LOCALITY}, ST=${STATE_PROVINCE}, C=${COUNTRY_CODE}" \
-validity "$CERT_VALIDITY_DAYS"

if [ $? -ne 0 ]; then
    echo "Error generating keystore.jks. Please check your configurations and retry."
    exit 1
fi
echo "keystore.jks created successfully."

# --- 4. Export NiFi's Public Certificate ---
echo "Exporting NiFi's public certificate to nifi_cert.cer..."
keytool -exportcert -alias "$CERT_ALIAS" -keystore keystore.jks \
-storepass "$KEYSTORE_PASSWORD" \
-file nifi_cert.cer

if [ $? -ne 0 ]; then
    echo "Error exporting nifi_cert.cer. Please check the keystore password."
    exit 1
fi
echo "nifi_cert.cer exported successfully."

# --- 5. Create Truststore and Import NiFi's Public Certificate ---
echo "Generating truststore.jks and importing NiFi's certificate..."
keytool -importcert -alias "$TRUST_ALIAS" -file nifi_cert.cer \
-keystore truststore.jks \
-storepass "$TRUSTSTORE_PASSWORD" \
-noprompt

if [ $? -ne 0 ]; then
    echo "Error importing certificate to truststore.jks. Please check the truststore password."
    exit 1
fi
echo "truststore.jks created successfully."

# --- 6. Clean up temporary certificate ---
echo "Removing temporary certificate file (nifi_cert.cer)..."
rm -f nifi_cert.cer

echo "--- NiFi certificate generation completed successfully ---"
