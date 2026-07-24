#!/bin/bash
set -e

# ===================================================
# W OS - Build IPA Script
# Chạy trên macOS có cài Xcode
# ===================================================

PROJECT="WOS.xcodeproj"
SCHEME="WOS"
ARCHIVE_PATH="build/WOS.xcarchive"
EXPORT_PATH="build/ipa"
EXPORT_OPTIONS="ExportOptions.plist"

echo "🔧 W OS - IPA Builder"
echo "===================="

# Bước 0: Kiểm tra XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo "❌ XcodeGen chưa cài. Đang cài..."
    brew install xcodegen
fi

# Bước 1: Generate project
echo ""
echo "📂 [1/5] Generating Xcode project..."
xcodegen generate

# Bước 2: Clean
echo ""
echo "🧹 [2/5] Cleaning build folder..."
rm -rf build/ derived_data/
mkdir -p build/ipa

# Bước 3: Archive
echo ""
echo "📦 [3/5] Archiving for iOS device..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination 'generic/platform=iOS' \
    -configuration Release \
    -derivedDataPath derived_data \
    -archivePath "$ARCHIVE_PATH"

echo "✅ Archive completed: $ARCHIVE_PATH"

# Bước 4: Export IPA
echo ""
echo "📤 [4/5] Exporting IPA..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    -exportPath "$EXPORT_PATH"

# Bước 5: Kiểm tra kết quả
echo ""
echo "📋 [5/5] Build results:"
echo "===================="
IPA_COUNT=$(find "$EXPORT_PATH" -name "*.ipa" 2>/dev/null | wc -l | tr -d ' ')

if [ "$IPA_COUNT" -gt 0 ]; then
    echo "✅ IPA files found:"
    find "$EXPORT_PATH" -name "*.ipa" -exec ls -lh {} \;
    echo ""
    echo "📁 Location: $(pwd)/$EXPORT_PATH/"
else
    echo "❌ No IPA generated."
    echo ""
    echo "Debug info:"
    echo "  - Archive exists: $(ls -la "$ARCHIVE_PATH" 2>/dev/null || echo 'NO')"
    echo "  - Export folder contents:"
    find "$EXPORT_PATH" -type f 2>/dev/null || echo "    (empty)"
    echo ""
    echo "⚠️  Possible fixes:"
    echo "   1. Check signing: open Xcode → Preferences → Accounts"
    echo "   2. Or edit ExportOptions.plist with your provisioning profile name"
    echo "   3. Or use: method = 'ad-hoc' with manual signing"
fi

echo ""
echo "Done! 🎉"
