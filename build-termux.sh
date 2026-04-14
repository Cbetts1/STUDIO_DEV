#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# Studio OS — Termux Build Script
# Builds the Studio OS APK from inside Termux on Android.
# Target: Samsung Galaxy S21 FE (ARM64, Android 12+)
# Usage: bash build-termux.sh [debug|release]
# ============================================================

set -e

BUILD_TYPE="${1:-debug}"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEYSTORE="$PROJECT_DIR/studio-release.jks"

echo "╔══════════════════════════════════════════════╗"
echo "║     Studio OS — Termux Build Script          ║"
echo "║     Build type: $BUILD_TYPE                        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── 1. Check dependencies ──────────────────────────────────
echo "[1/6] Checking dependencies…"

check_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[!] $1 not found. Installing…"
        pkg install -y "$2"
    else
        echo "[✓] $1 found"
    fi
}

check_cmd java   openjdk-17
check_cmd git    git
check_cmd curl   curl
check_cmd unzip  unzip

# ── Set JAVA_HOME if not already set ──────────────────────
if [ -z "$JAVA_HOME" ]; then
    JAVA_BIN="$(command -v java)"
    if [ -n "$JAVA_BIN" ]; then
        # Resolve symlinks to get the real path, then go up two levels (bin/java → jre/.. → java_home)
        JAVA_REAL="$(readlink -f "$JAVA_BIN" 2>/dev/null || realpath "$JAVA_BIN" 2>/dev/null || echo "$JAVA_BIN")"
        JAVA_HOME="$(dirname "$(dirname "$JAVA_REAL")")"
        export JAVA_HOME
        echo "[✓] JAVA_HOME set to $JAVA_HOME"
    else
        echo "[!] WARNING: Could not determine JAVA_HOME"
    fi
else
    echo "[✓] JAVA_HOME already set to $JAVA_HOME"
fi

# ── 2. Download Android SDK Command-line Tools ────────────
echo ""
echo "[2/6] Setting up Android SDK…"

SDK_DIR="$HOME/android-sdk"
if [ ! -d "$SDK_DIR/cmdline-tools/latest/bin" ]; then
    mkdir -p "$SDK_DIR"
    SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
    echo "  Downloading SDK tools…"
    TMPDIR="${TMPDIR:-$HOME/tmp}"
    mkdir -p "$TMPDIR"
    curl -L "$SDK_URL" -o "$TMPDIR/sdk-tools.zip"
    unzip -q "$TMPDIR/sdk-tools.zip" -d "$SDK_DIR/cmdline-tools"
    mv "$SDK_DIR/cmdline-tools/cmdline-tools" "$SDK_DIR/cmdline-tools/latest" 2>/dev/null || true
    rm "$TMPDIR/sdk-tools.zip"
fi

export ANDROID_SDK_ROOT="$SDK_DIR"
export PATH="$SDK_DIR/cmdline-tools/latest/bin:$SDK_DIR/platform-tools:$PATH"

# ── 3. Accept licenses & install build tools ──────────────
echo ""
echo "[3/6] Installing SDK components (may take a few minutes)…"

# Accept all SDK licenses (two methods for reliability in Termux)
mkdir -p "$SDK_DIR/licenses"
echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "$SDK_DIR/licenses/android-sdk-license"
echo "84831b9409646a918e30573bab4c9c91346d8abd" >> "$SDK_DIR/licenses/android-sdk-license"
echo "d975f751698a77b662f1254ddbeed3901e976f5a" > "$SDK_DIR/licenses/android-sdk-preview-license"
echo "601085b94cd77f0b54ff86406957099ebe79c4d6" > "$SDK_DIR/licenses/android-googletv-license"
echo "33b6a2b64607f11b759f320ef9dff4ae5c47d97a" > "$SDK_DIR/licenses/android-sdk-arm-dbt-license"
echo "859f317696f67ef3d7f30a50a5560e7834b43903" > "$SDK_DIR/licenses/android-sdk-preview-license"
yes | sdkmanager --licenses > /dev/null 2>&1 || true

sdkmanager \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "ndk;26.3.11579264" \
    "cmake;3.22.1" || {
    echo "[!] sdkmanager failed — if offline, manually install SDK"
}

export ANDROID_HOME="$SDK_DIR"
export NDK_HOME="$SDK_DIR/ndk/26.3.11579264"
export ANDROID_NDK_HOME="$NDK_HOME"
export ANDROID_NDK_ROOT="$NDK_HOME"

# ── 3.5. ARM64 AAPT2 override ─────────────────────────────
# The AAPT2 bundled with AGP is an x86_64 binary and will not run on
# ARM64 Termux. Detect the architecture and substitute a native binary.
AAPT2_FLAG=""
if [ "$(uname -m)" = "aarch64" ]; then
    echo ""
    echo "[3.5/6] ARM64 detected — locating native aapt2 binary…"

    # 1) Try a aapt2 already installed via Termux packages (pkg install aapt2)
    AAPT2_SYSTEM="$(command -v aapt2 2>/dev/null)"
    if [ -n "$AAPT2_SYSTEM" ]; then
        echo "[✓] Using system aapt2: $AAPT2_SYSTEM"
        AAPT2_FLAG="-Pandroid.aapt2FromMavenOverride=$AAPT2_SYSTEM"
    else
        # 2) Download from lzhiyong/android-sdk-tools ARM64 release
        AAPT2_DIR="$HOME/aapt2-aarch64"
        AAPT2_BIN="$AAPT2_DIR/aapt2"
        if [ ! -f "$AAPT2_BIN" ]; then
            mkdir -p "$AAPT2_DIR"
            AAPT2_URL="https://github.com/lzhiyong/android-sdk-tools/releases/download/34.0.0/android-sdk-tools-aarch64.zip"
            echo "  Downloading ARM64 aapt2 from lzhiyong/android-sdk-tools…"
            TMPDIR="${TMPDIR:-$HOME/tmp}"
            mkdir -p "$TMPDIR"
            if curl -fL "$AAPT2_URL" -o "$TMPDIR/aapt2-aarch64.zip"; then
                if ! unzip -j -q "$TMPDIR/aapt2-aarch64.zip" "*/aapt2" -d "$AAPT2_DIR"; then
                    echo "[!] Failed to extract aapt2 — archive may be corrupt or the path inside zip changed."
                fi
                chmod +x "$AAPT2_BIN" 2>/dev/null || true
                rm -f "$TMPDIR/aapt2-aarch64.zip"
            else
                echo "[!] Download failed. Trying: pkg install aapt2"
                if ! pkg install -y aapt2; then
                    echo "[!] pkg install aapt2 also failed — aapt2 may not be in your Termux repo."
                fi
                AAPT2_SYSTEM="$(command -v aapt2 2>/dev/null)"
                if [ -n "$AAPT2_SYSTEM" ]; then
                    AAPT2_BIN="$AAPT2_SYSTEM"
                fi
            fi
        fi
        if [ -f "$AAPT2_BIN" ]; then
            echo "[✓] ARM64 aapt2 ready: $AAPT2_BIN"
            AAPT2_FLAG="-Pandroid.aapt2FromMavenOverride=$AAPT2_BIN"
        else
            echo "[!] WARNING: Could not obtain ARM64 aapt2."
            echo "    Run:  pkg install aapt2"
            echo "    then re-run this script. Build will likely fail without it."
        fi
    fi
fi

# ── 4. Setup Gradle wrapper ────────────────────────────────
echo ""
echo "[4/6] Setting up Gradle…"

cd "$PROJECT_DIR"
if [ ! -f "gradlew" ]; then
    # Download Gradle 8.6 manually if wrapper not available
    GRADLE_VER="8.6"
    GRADLE_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VER}-bin.zip"
    GRADLE_DIR="$HOME/.gradle/wrapper/dists/gradle-${GRADLE_VER}-bin"
    mkdir -p "$GRADLE_DIR"
    if [ ! -f "$GRADLE_DIR/gradle-${GRADLE_VER}/bin/gradle" ]; then
        echo "  Downloading Gradle $GRADLE_VER…"
        curl -L "$GRADLE_URL" -o "$TMPDIR/gradle.zip"
        unzip -q "$TMPDIR/gradle.zip" -d "$GRADLE_DIR"
        rm "$TMPDIR/gradle.zip"
    fi
    GRADLE="$GRADLE_DIR/gradle-${GRADLE_VER}/bin/gradle"
else
    chmod +x gradlew
    GRADLE="./gradlew"
fi

# ── 5. Build ───────────────────────────────────────────────
echo ""
echo "[5/6] Building Studio OS APK (type: $BUILD_TYPE)…"

if [ "$BUILD_TYPE" = "release" ]; then
    # Create keystore if it doesn't exist
    if [ ! -f "$KEYSTORE" ]; then
        echo "[!] No keystore found. Creating debug keystore for signing…"
        keytool -genkey -v \
            -keystore "$KEYSTORE" \
            -alias studio \
            -keyalg RSA \
            -keysize 2048 \
            -validity 10000 \
            -storepass studiokey \
            -keypass studiokey \
            -dname "CN=Studio OS, OU=Studio, O=StudioOS, L=Unknown, S=Unknown, C=US" 2>/dev/null
    fi

    $GRADLE assembleRelease $AAPT2_FLAG \
        -Pandroid.injected.signing.store.file="$KEYSTORE" \
        -Pandroid.injected.signing.store.password=studiokey \
        -Pandroid.injected.signing.key.alias=studio \
        -Pandroid.injected.signing.key.password=studiokey

    APK="$PROJECT_DIR/app/build/outputs/apk/release/app-release.apk"
else
    $GRADLE assembleDebug $AAPT2_FLAG
    APK="$PROJECT_DIR/app/build/outputs/apk/debug/app-debug.apk"
fi

# ── 6. Done ────────────────────────────────────────────────
echo ""
echo "[6/6] Build complete!"
echo ""

if [ -f "$APK" ]; then
    echo "╔══════════════════════════════════════════════╗"
    echo "║             BUILD SUCCESSFUL!                ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    echo "  APK: $APK"
    SIZE=$(du -sh "$APK" | cut -f1)
    echo "  Size: $SIZE"
    echo ""
    echo "  To install on your device:"
    echo "  1) Install directly from Termux (no ADB needed):"
    echo ""
    echo "     termux-open \"$APK\""
    echo "     — or —"
    echo "     pm install -r \"$APK\""
    echo ""
    echo "  2) If ADB is available (USB/wireless debug from another machine):"
    echo ""
    echo "     adb install -r \"$APK\""
    echo ""
    echo "  3) Open the APK file in the Files / Downloads app"
    echo "     (enable Unknown Sources in Settings → Security first)"
    echo ""
    cp "$APK" "$PROJECT_DIR/StudioOS-${BUILD_TYPE}.apk" 2>/dev/null || true
    echo "  Also copied to: $PROJECT_DIR/StudioOS-${BUILD_TYPE}.apk"
else
    echo "[✗] Build failed — APK not found at expected path."
    echo "    Check the output above for errors."
    exit 1
fi
