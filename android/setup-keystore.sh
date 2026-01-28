#!/bin/bash

# Interactive script to set up keystore passwords in key.properties
# This script helps you securely configure your release signing

echo "🔐 Love Connect - Keystore Setup"
echo "=================================="
echo ""
echo "This script will help you configure your release signing."
echo ""

# Check if keystore exists
if [ ! -f "upload-keystore.jks" ]; then
    echo "❌ Error: upload-keystore.jks not found!"
    echo ""
    echo "Please create the keystore first:"
    echo "  ./create-keystore.sh"
    echo ""
    exit 1
fi

echo "✅ Keystore found: upload-keystore.jks"
echo ""

# Check if key.properties exists
if [ ! -f "key.properties" ]; then
    echo "❌ Error: key.properties not found!"
    exit 1
fi

echo "📝 Please enter your keystore passwords:"
echo ""

# Read passwords securely
read -sp "Enter keystore password (storePassword): " STORE_PASSWORD
echo ""
read -sp "Enter key password (keyPassword, can be same as storePassword): " KEY_PASSWORD
echo ""
echo ""

# Verify keystore with provided password
echo "🔍 Verifying keystore..."
if keytool -list -v -keystore upload-keystore.jks -alias upload -storepass "$STORE_PASSWORD" > /dev/null 2>&1; then
    echo "✅ Keystore verified successfully!"
else
    echo "❌ Error: Keystore verification failed. Please check your password."
    exit 1
fi

# Update key.properties
echo ""
echo "📝 Updating key.properties..."

# Create backup
cp key.properties key.properties.backup

# Update the file
cat > key.properties << EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
EOF

echo "✅ key.properties updated successfully!"
echo ""
echo "📋 Configuration:"
echo "  - Keystore: upload-keystore.jks"
echo "  - Alias: upload"
echo "  - Store Password: [HIDDEN]"
echo "  - Key Password: [HIDDEN]"
echo ""
echo "✅ Setup complete! You can now build release APK/AAB."
echo ""
echo "⚠️  IMPORTANT:"
echo "  - Keep your passwords safe!"
echo "  - Backup key.properties.backup has been created"
echo "  - Never commit key.properties with real passwords to git"
echo ""
