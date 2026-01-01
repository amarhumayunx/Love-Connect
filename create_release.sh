#!/bin/bash

# Script to create GitHub release and upload APK and iOS archive
# Usage: ./create_release.sh <github_token>

set -e

REPO_OWNER="amarhumayunx"
REPO_NAME="Love-Connect"
VERSION="v1.0.0"
TAG_NAME="v1.0.0"
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
IOS_ARCHIVE_PATH="build/ios/archive/Runner.xcarchive"

if [ -z "$1" ]; then
    echo "Error: GitHub token is required"
    echo "Usage: $0 <github_token>"
    echo ""
    echo "You can create a token at: https://github.com/settings/tokens"
    echo "The token needs 'repo' scope."
    exit 1
fi

GITHUB_TOKEN=$1

echo "Creating GitHub release for $TAG_NAME..."

# Check if token works and has proper permissions
echo "Verifying token permissions..."
REPO_CHECK=$(curl -s -w "\n%{http_code}" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME")

HTTP_CODE=$(echo "$REPO_CHECK" | tail -n1)
REPO_RESPONSE=$(echo "$REPO_CHECK" | sed '$d')

if [ "$HTTP_CODE" != "200" ]; then
    echo "Error: Token authentication failed (HTTP $HTTP_CODE)"
    echo "Response: $REPO_RESPONSE"
    echo ""
    echo "Please ensure your token has the following permissions:"
    echo "- Contents: Read and write"
    echo "- Metadata: Read-only"
    echo ""
    echo "For fine-grained tokens, make sure the token has access to this repository."
    exit 1
fi

echo "Token verified successfully."

# Create the release (try Bearer first, then token)
RELEASE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases" \
  -d "{
    \"tag_name\": \"$TAG_NAME\",
    \"name\": \"Release $VERSION\",
    \"body\": \"## Release $VERSION\\n\\n### Android\\n- APK file included\\n\\n### iOS\\n- Xcode archive included (requires proper code signing to create IPA)\\n\\n### Changes\\n- Update app assets, add new services and widgets, improve profile screen\",
    \"draft\": false,
    \"prerelease\": false
  }")

RELEASE_HTTP_CODE=$(echo "$RELEASE_RESPONSE" | tail -n1)
RELEASE_BODY=$(echo "$RELEASE_RESPONSE" | sed '$d')

if [ "$RELEASE_HTTP_CODE" != "201" ]; then
    # Try with "token" authentication instead
    echo "Bearer auth failed, trying token authentication..."
    RELEASE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases" \
      -d "{
        \"tag_name\": \"$TAG_NAME\",
        \"name\": \"Release $VERSION\",
        \"body\": \"## Release $VERSION\\n\\n### Android\\n- APK file included\\n\\n### iOS\\n- Xcode archive included (requires proper code signing to create IPA)\\n\\n### Changes\\n- Update app assets, add new services and widgets, improve profile screen\",
        \"draft\": false,
        \"prerelease\": false
      }")
    RELEASE_HTTP_CODE=$(echo "$RELEASE_RESPONSE" | tail -n1)
    RELEASE_BODY=$(echo "$RELEASE_RESPONSE" | sed '$d')
fi

if [ "$RELEASE_HTTP_CODE" != "201" ]; then
    echo "Error: Failed to create release (HTTP $RELEASE_HTTP_CODE)"
    echo "Response: $RELEASE_BODY"
    echo ""
    echo "This usually means the token doesn't have sufficient permissions."
    echo "Please ensure your token has:"
    echo "- Contents: Read and write (for creating releases)"
    echo "- Metadata: Read-only"
    exit 1
fi

# Extract upload URL from response (using Python for JSON parsing, works on macOS)
UPLOAD_URL=$(echo "$RELEASE_BODY" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('upload_url', '').replace('{?name,label}', ''))" 2>/dev/null)
RELEASE_ID=$(echo "$RELEASE_BODY" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('id', ''))" 2>/dev/null)

if [ -z "$UPLOAD_URL" ] || [ -z "$RELEASE_ID" ]; then
    echo "Error: Failed to parse release response"
    echo "Response: $RELEASE_BODY"
    exit 1
fi

echo "Release created successfully (ID: $RELEASE_ID)"
echo "Upload URL: $UPLOAD_URL"

# Upload APK
if [ -f "$APK_PATH" ]; then
    echo "Uploading APK..."
    APK_NAME="Love-Connect-$VERSION.apk"
    curl -s -X POST \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: application/vnd.android.package-archive" \
      --data-binary @"$APK_PATH" \
      "$UPLOAD_URL?name=$APK_NAME" > /dev/null
    echo "✓ APK uploaded: $APK_NAME"
else
    echo "Warning: APK not found at $APK_PATH"
fi

# Upload iOS archive as a zip
if [ -d "$IOS_ARCHIVE_PATH" ]; then
    echo "Uploading iOS archive..."
    ARCHIVE_ZIP="Love-Connect-$VERSION-ios.xcarchive.zip"
    cd "$(dirname "$IOS_ARCHIVE_PATH")"
    zip -r -q "$ARCHIVE_ZIP" "$(basename "$IOS_ARCHIVE_PATH")"
    cd - > /dev/null
    
    curl -s -X POST \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: application/zip" \
      --data-binary @"$(dirname "$IOS_ARCHIVE_PATH")/$ARCHIVE_ZIP" \
      "$UPLOAD_URL?name=$ARCHIVE_ZIP" > /dev/null
    echo "✓ iOS archive uploaded: $ARCHIVE_ZIP"
    
    # Clean up zip file
    rm "$(dirname "$IOS_ARCHIVE_PATH")/$ARCHIVE_ZIP"
else
    echo "Warning: iOS archive not found at $IOS_ARCHIVE_PATH"
fi

echo ""
echo "Release created successfully!"
echo "View it at: https://github.com/$REPO_OWNER/$REPO_NAME/releases/tag/$TAG_NAME"

