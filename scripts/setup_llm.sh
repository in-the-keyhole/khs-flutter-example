#!/bin/bash

# Setup script for local LLM (fllama) platform requirements
# Supports: iOS, Android
# Web: Not supported by fllama 0.0.1

# Don't exit on error - we want to continue checking other platforms
set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

OS=$(detect_os)

print_header "Local LLM Setup Script"
echo "Detected OS: $OS"
echo "Project directory: $PROJECT_DIR"

# ============================================
# iOS Setup (macOS only)
# ============================================
setup_ios() {
    print_header "iOS Setup"

    if [ "$OS" != "macos" ]; then
        print_warning "iOS setup requires macOS. Skipping..."
        return
    fi

    if ! command_exists pod; then
        print_error "CocoaPods not found. Install with: brew install cocoapods"
        return 1
    fi

    print_success "CocoaPods found: $(pod --version 2>/dev/null || echo 'version check failed')"

    cd "$PROJECT_DIR/ios"

    if [ -f "Podfile" ]; then
        print_info "Running pod install..."
        # Set UTF-8 encoding for CocoaPods
        export LANG=en_US.UTF-8
        export LC_ALL=en_US.UTF-8

        if pod install --repo-update 2>&1; then
            print_success "iOS pods installed"
        else
            print_warning "pod install failed. Try running manually:"
            echo "  cd ios && LANG=en_US.UTF-8 pod install"
        fi
    else
        print_warning "No Podfile found in ios/. Run 'flutter build ios' first."
    fi

    cd "$PROJECT_DIR"

    # Check Xcode
    if command_exists xcodebuild; then
        XCODE_VERSION=$(xcodebuild -version | head -n1)
        print_success "Xcode found: $XCODE_VERSION"
    else
        print_warning "Xcode not found. Install from App Store."
    fi

    echo ""
    print_info "iOS Notes:"
    echo "  - Minimum iOS version: 14.0"
    echo "  - Metal GPU acceleration requires Apple7 GPU (A14+)"
    echo "  - Simulator does not support Metal acceleration"
}

# ============================================
# Android Setup
# ============================================
setup_android() {
    print_header "Android Setup"

    # Check for Android SDK
    if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
        print_warning "ANDROID_HOME or ANDROID_SDK_ROOT not set"

        # Try common locations
        if [ -d "$HOME/Library/Android/sdk" ]; then
            export ANDROID_HOME="$HOME/Library/Android/sdk"
            print_info "Found Android SDK at: $ANDROID_HOME"
        elif [ -d "$HOME/Android/Sdk" ]; then
            export ANDROID_HOME="$HOME/Android/Sdk"
            print_info "Found Android SDK at: $ANDROID_HOME"
        else
            print_error "Android SDK not found. Install Android Studio."
            return 1
        fi
    fi

    ANDROID_SDK="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
    print_success "Android SDK: $ANDROID_SDK"

    # Check SDK version
    if [ -d "$ANDROID_SDK/platforms" ]; then
        INSTALLED_PLATFORMS=$(ls "$ANDROID_SDK/platforms" 2>/dev/null | sort -V | tail -n1)
        if [ -n "$INSTALLED_PLATFORMS" ]; then
            print_success "Latest platform: $INSTALLED_PLATFORMS"

            # Check for SDK 35
            if [ -d "$ANDROID_SDK/platforms/android-35" ]; then
                print_success "Android SDK 35 found"
            else
                print_warning "Android SDK 35 not found. Install via SDK Manager."
                echo "  Run: sdkmanager \"platforms;android-35\""
            fi
        fi
    fi

    # Check NDK
    REQUIRED_NDK="28.0.12433566"
    if [ -d "$ANDROID_SDK/ndk" ]; then
        if [ -d "$ANDROID_SDK/ndk/$REQUIRED_NDK" ]; then
            print_success "NDK $REQUIRED_NDK found"
        else
            INSTALLED_NDK=$(ls "$ANDROID_SDK/ndk" 2>/dev/null | sort -V | tail -n1)
            if [ -n "$INSTALLED_NDK" ]; then
                print_warning "NDK $REQUIRED_NDK not found. Installed: $INSTALLED_NDK"
            else
                print_warning "No NDK installed"
            fi
            echo "  Install required NDK: sdkmanager \"ndk;$REQUIRED_NDK\""
        fi
    else
        print_warning "NDK directory not found"
        echo "  Install: sdkmanager \"ndk;$REQUIRED_NDK\""
    fi

    # Check CMake
    if [ -d "$ANDROID_SDK/cmake" ]; then
        INSTALLED_CMAKE=$(ls "$ANDROID_SDK/cmake" 2>/dev/null | sort -V | tail -n1)
        if [ -n "$INSTALLED_CMAKE" ]; then
            print_success "CMake found: $INSTALLED_CMAKE"

            if [[ "$INSTALLED_CMAKE" == 3.31* ]]; then
                print_success "CMake 3.31.x found"
            else
                print_warning "CMake 3.31.0 recommended. Install via SDK Manager."
                echo "  Run: sdkmanager \"cmake;3.31.0\""
            fi
        fi
    else
        print_warning "CMake not found in Android SDK"
        echo "  Install: sdkmanager \"cmake;3.31.0\""
    fi

    echo ""
    print_info "Android Notes:"
    echo "  - Minimum API level: 23"
    echo "  - Supported ABIs: arm64-v8a, x86_64, armeabi-v7a"
    echo "  - 64-bit recommended for larger models"
    echo "  - GPU acceleration not yet integrated"
}

# ============================================
# Web Setup (Not supported)
# ============================================
setup_web() {
    print_header "Web Setup"

    print_warning "fllama 0.0.1 does NOT support web platform"
    echo ""
    print_info "Alternatives for web:"
    echo "  1. Use a remote LLM API (OpenAI, Anthropic, etc.)"
    echo "  2. Use WebLLM (https://webllm.mlc.ai/) - separate integration"
    echo "  3. Wait for fllama web support (WASM-based)"
    echo ""
    echo "For now, consider implementing a fallback in your client:"
    echo "  - Mobile: Use local LLM via fllama"
    echo "  - Web: Use remote API endpoint"
}

# ============================================
# Model Download Helper
# ============================================
setup_models() {
    print_header "Model Setup"

    MODELS_DIR="$PROJECT_DIR/assets/models"

    print_info "Recommended models for mobile:"
    echo ""
    echo "  TinyLlama 1.1B (smallest, ~700MB Q4):"
    echo "    https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF"
    echo ""
    echo "  Phi-2 2.7B (better quality, ~1.6GB Q4):"
    echo "    https://huggingface.co/TheBloke/phi-2-GGUF"
    echo ""
    echo "  Gemma 2B (good instruction following, ~1.5GB Q4):"
    echo "    https://huggingface.co/google/gemma-2b-it-GGUF"
    echo ""
    print_info "Download .gguf files and place in your app's documents directory"
    print_info "Or bundle smaller models in assets (increases app size significantly)"
}

# ============================================
# Flutter Setup
# ============================================
setup_flutter() {
    print_header "Flutter Setup"

    if ! command_exists flutter; then
        print_error "Flutter not found. Install from https://flutter.dev"
        return 1
    fi

    FLUTTER_VERSION=$(flutter --version | head -n1)
    print_success "Flutter: $FLUTTER_VERSION"

    cd "$PROJECT_DIR"

    print_info "Running flutter pub get..."
    flutter pub get

    print_info "Checking project..."
    flutter analyze lib/src/clients/local_llm_client.dart || true
}

# ============================================
# Main
# ============================================
main() {
    local target="${1:-all}"

    case "$target" in
        ios)
            setup_ios
            ;;
        android)
            setup_android
            ;;
        web)
            setup_web
            ;;
        models)
            setup_models
            ;;
        flutter)
            setup_flutter
            ;;
        all)
            setup_flutter
            setup_ios
            setup_android
            setup_web
            setup_models
            ;;
        *)
            echo "Usage: $0 [ios|android|web|models|flutter|all]"
            echo ""
            echo "  ios      - Setup iOS dependencies (CocoaPods)"
            echo "  android  - Check Android SDK/NDK requirements"
            echo "  web      - Show web platform status"
            echo "  models   - Show recommended models"
            echo "  flutter  - Run flutter pub get and analyze"
            echo "  all      - Run all setup steps (default)"
            exit 1
            ;;
    esac

    echo ""
    print_header "Setup Complete"
    print_info "Run 'flutter build ios' or 'flutter build apk' to test"
}

main "$@"
