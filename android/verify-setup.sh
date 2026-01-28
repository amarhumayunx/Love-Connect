#!/bin/bash

# Script to verify all setup steps are complete

echo "🔍 Love Connect - Setup Verification"
echo "====================================="
echo ""

ERRORS=0
WARNINGS=0

# Check 1: Keystore exists
echo "1️⃣  Checking keystore..."
if [ -f "upload-keystore.jks" ]; then
    echo "   ✅ Keystore found: upload-keystore.jks"
else
    echo "   ❌ Keystore not found!"
    echo "      Run: ./create-keystore.sh"
    ERRORS=$((ERRORS + 1))
fi

# Check 2: key.properties exists
echo ""
echo "2️⃣  Checking key.properties..."
if [ -f "key.properties" ]; then
    if grep -q "YOUR_STORE_PASSWORD_HERE" key.properties || grep -q "YOUR_KEY_PASSWORD_HERE" key.properties; then
        echo "   ⚠️  key.properties has placeholder passwords"
        echo "      Run: ./setup-keystore.sh"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "   ✅ key.properties configured"
    fi
else
    echo "   ❌ key.properties not found!"
    ERRORS=$((ERRORS + 1))
fi

# Check 3: Package name in build.gradle.kts
echo ""
echo "3️⃣  Checking package name..."
if grep -q 'applicationId = "com.loveconnect.app"' app/build.gradle.kts; then
    echo "   ✅ Package name correct: com.loveconnect.app"
else
    echo "   ❌ Package name incorrect!"
    ERRORS=$((ERRORS + 1))
fi

# Check 4: Release signing config
echo ""
echo "4️⃣  Checking release signing configuration..."
if grep -q 'signingConfigs.getByName("release")' app/build.gradle.kts; then
    echo "   ✅ Release signing configured"
else
    echo "   ❌ Release signing not configured!"
    ERRORS=$((ERRORS + 1))
fi

# Check 5: MainActivity package
echo ""
echo "5️⃣  Checking MainActivity..."
if [ -f "app/src/main/kotlin/com/loveconnect/app/MainActivity.kt" ]; then
    if grep -q "package com.loveconnect.app" app/src/main/kotlin/com/loveconnect/app/MainActivity.kt; then
        echo "   ✅ MainActivity package correct"
    else
        echo "   ⚠️  MainActivity package may be incorrect"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "   ❌ MainActivity not found in expected location!"
    ERRORS=$((ERRORS + 1))
fi

# Check 6: google-services.json package name
echo ""
echo "6️⃣  Checking Firebase configuration..."
if grep -q '"package_name": "com.loveconnect.app"' app/google-services.json; then
    echo "   ✅ Firebase package name correct"
else
    echo "   ⚠️  Firebase package name may need update"
    echo "      See: FIREBASE_SETUP_INSTRUCTIONS.md"
    WARNINGS=$((WARNINGS + 1))
fi

# Summary
echo ""
echo "====================================="
echo "📊 Verification Summary"
echo "====================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ All checks passed! Setup is complete."
    echo ""
    echo "Next steps:"
    echo "  1. Update Firebase Console (if not done)"
    echo "  2. Test build: flutter build appbundle --release"
    echo "  3. Upload to Google Play Store"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  Setup mostly complete, but has $WARNINGS warning(s)."
    echo "   Review warnings above and fix if needed."
    exit 0
else
    echo "❌ Setup incomplete! Found $ERRORS error(s) and $WARNINGS warning(s)."
    echo "   Please fix the errors above before proceeding."
    exit 1
fi
