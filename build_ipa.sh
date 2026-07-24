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
rm -rf build/
mkdir -p build/ipa

# Bước 3: Archive
echo ""
echo "📦 [3/5] Archiving for iOS device..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination 'generic/platform=iOS' \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

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
if ls "$EXPORT_PATH"/*.ipa 1> /dev/null 2>&1; then
    echo "✅ IPA files:"
    ls -lh "$EXPORT_PATH"/*.ipa
    echo ""
    echo "📁 Location: $(pwd)/$EXPORT_PATH/"
else
    echo "❌ No IPA generated. Check signing configuration."
    echo ""
    echo "⚠️  To fix signing, edit ExportOptions.plist:"
    echo "   - Change method to 'app-store' or 'ad-hoc'"
    echo "   - Add your provisioningProfiles with actual profile names"
    echo "   - Or use Xcode automatic signing"
fi

echo ""
echo "Done! 🎉"
