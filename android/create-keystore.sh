#!/bin/bash

# Script to create release keystore for Love Connect app
# Run this script from the android/ directory

echo "🔐 Creating release keystore for Love Connect..."
echo ""
echo "You will be asked to enter:"
echo "  - Keystore password (storePassword)"
echo "  - Key password (keyPassword) - can be same as keystore password"
echo "  - Your name and organization details"
echo ""
echo "⚠️  IMPORTANT: Save these passwords securely! You'll need them for future updates."
echo ""

keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

echo ""
echo "✅ Keystore created successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Update android/key.properties with your passwords"
echo "2. Make sure upload-keystore.jks is in android/ directory"
echo "3. Add upload-keystore.jks to .gitignore (IMPORTANT - never commit this file!)"
echo ""
