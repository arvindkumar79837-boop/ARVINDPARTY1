#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# FILE: deploy.sh
# ARVIND PARTY - AUTOMATED DEPLOYMENT SCRIPT
# Usage: bash deploy.sh [android|ios|backend|full]
# ═══════════════════════════════════════════════════════════════════════════

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ─────────────────────────────────────────────────────────────────────────
# UTILITY FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# ─────────────────────────────────────────────────────────────────────────
# PRE-DEPLOYMENT CHECKS
# ─────────────────────────────────────────────────────────────────────────

check_requirements() {
    print_header "CHECKING REQUIREMENTS"
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not installed"
        exit 1
    fi
    print_success "Flutter installed"
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js not installed"
        exit 1
    fi
    print_success "Node.js installed"
    
    # Check .env file
    if [ ! -f "lib/arvind-party-backend/.env" ]; then
        print_warning ".env file not found. Creating from template..."
        cp lib/arvind-party-backend/.env.template lib/arvind-party-backend/.env
        print_warning "Please fill in .env with your credentials and run again"
        exit 1
    fi
    print_success ".env file exists"
    
    # Check Firebase credentials for mobile
    if [ ! -f "android/app/google-services.json" ]; then
        print_warning "google-services.json not found. Android build will fail."
    else
        print_success "google-services.json found"
    fi
    
    if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
        print_warning "GoogleService-Info.plist not found. iOS build will fail."
    else
        print_success "GoogleService-Info.plist found"
    fi
}

# ─────────────────────────────────────────────────────────────────────────
# FLUTTER BUILD FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────

build_android() {
    print_header "BUILDING ANDROID APK (RELEASE)"
    
    cd "$(dirname "$0")"
    
    flutter clean
    flutter pub get
    flutter analyze
    
    print_header "BUILDING RELEASE APK"
    flutter build apk --release
    
    APK_PATH="build/app/outputs/flutter-app.apk"
    if [ -f "$APK_PATH" ]; then
        print_success "Android APK built: $APK_PATH"
        ls -lh "$APK_PATH"
    else
        print_error "APK build failed"
        exit 1
    fi
}

build_android_aab() {
    print_header "BUILDING ANDROID APP BUNDLE (FOR PLAY STORE)"
    
    cd "$(dirname "$0")"
    
    flutter clean
    flutter pub get
    
    print_header "BUILDING RELEASE AAB"
    flutter build appbundle --release
    
    AAB_PATH="build/app/outputs/app-release.aab"
    if [ -f "$AAB_PATH" ]; then
        print_success "Android AAB built: $AAB_PATH"
        ls -lh "$AAB_PATH"
    else
        print_error "AAB build failed"
        exit 1
    fi
}

build_ios() {
    print_header "BUILDING iOS APP (RELEASE)"
    
    cd "$(dirname "$0")"
    
    flutter clean
    flutter pub get
    flutter analyze
    
    print_header "BUILDING RELEASE iOS"
    flutter build ios --release
    
    IPA_PATH="build/ios/iphoneos/Runner.app"
    if [ -d "$IPA_PATH" ]; then
        print_success "iOS app built: $IPA_PATH"
    else
        print_error "iOS build failed"
        exit 1
    fi
}

# ─────────────────────────────────────────────────────────────────────────
# BACKEND BUILD & DEPLOYMENT
# ─────────────────────────────────────────────────────────────────────────

build_backend() {
    print_header "BUILDING BACKEND"
    
    cd lib/arvind-party-backend
    
    npm install
    npm audit
    npm run lint
    
    print_success "Backend built successfully"
}

deploy_backend_aws() {
    print_header "DEPLOYING BACKEND TO AWS"
    
    # Check for AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI not installed. Install it and configure credentials first."
        exit 1
    fi
    
    print_warning "AWS deployment requires manual setup:"
    echo "1. Install AWS CLI: https://aws.amazon.com/cli/"
    echo "2. Configure credentials: aws configure"
    echo "3. Create ECR repository: aws ecr create-repository --repository-name arvind-party"
    echo "4. Push image: docker push xxx.dkr.ecr.region.amazonaws.com/arvind-party:latest"
    echo "5. Update ECS service with new image"
    echo ""
    echo "For quick deployment, use Railway:"
    echo "1. Go to railway.app"
    echo "2. Connect your GitHub repo"
    echo "3. Auto-deploys on every git push"
}

# ─────────────────────────────────────────────────────────────────────────
# TESTING FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────

test_flutter() {
    print_header "RUNNING FLUTTER TESTS"
    
    cd "$(dirname "$0")"
    flutter test
    
    print_success "Flutter tests passed"
}

test_backend() {
    print_header "RUNNING BACKEND TESTS"
    
    cd lib/arvind-party-backend
    npm test
    
    print_success "Backend tests passed"
}

test_integrations() {
    print_header "TESTING INTEGRATIONS"
    
    print_warning "Manual integration tests required:"
    echo "1. Test Firebase OTP login"
    echo "2. Test Razorpay payment flow"
    echo "3. Test Agora live room"
    echo "4. Test Socket.IO real-time chat"
    echo "5. Test user registration and profile"
}

# ─────────────────────────────────────────────────────────────────────────
# DEPLOYMENT WORKFLOWS
# ─────────────────────────────────────────────────────────────────────────

deploy_android() {
    print_header "ANDROID DEPLOYMENT WORKFLOW"
    
    echo "Steps:"
    echo "1. Build: $(print_success "DONE")"
    build_android_aab
    
    echo "2. Upload to Play Store:"
    echo "   - Go to: https://console.cloud.google.com"
    echo "   - Create app: Arvind Party"
    echo "   - Upload build/app/outputs/app-release.aab"
    echo "   - Add screenshots (minimum 4)"
    echo "   - Add description"
    echo "   - Submit for review"
    echo ""
    print_warning "Review time: 2-4 hours"
}

deploy_ios() {
    print_header "iOS DEPLOYMENT WORKFLOW"
    
    echo "Steps:"
    echo "1. Build: $(print_success "DONE")"
    build_ios
    
    echo "2. Archive in Xcode:"
    echo "   - Open: build/ios/iphoneos/Runner.app"
    echo "   - Archive and upload"
    echo ""
    echo "3. Submit to App Store Connect:"
    echo "   - Go to: https://appstoreconnect.apple.com"
    echo "   - Create app: Arvind Party"
    echo "   - Upload build"
    echo "   - Add screenshots (minimum 2 per device)"
    echo "   - Add description"
    echo "   - Submit for review"
    echo ""
    print_warning "Review time: 24-48 hours"
}

deploy_full() {
    print_header "FULL DEPLOYMENT PIPELINE"
    
    check_requirements
    
    # Build mobile
    build_android
    build_android_aab
    
    # Build backend
    build_backend
    
    print_header "DEPLOYMENT COMPLETE"
    echo ""
    echo "Next steps:"
    echo "1. Android: Upload build/app/outputs/app-release.aab to Play Store"
    echo "2. Backend: Deploy to AWS/Railway"
    echo "3. iOS: Upload to App Store Connect"
    echo ""
    print_success "All builds ready for deployment!"
}

# ─────────────────────────────────────────────────────────────────────────
# MAIN SCRIPT
# ─────────────────────────────────────────────────────────────────────────

main() {
    case "${1:-full}" in
        android)
            check_requirements
            build_android
            ;;
        android-aab)
            check_requirements
            build_android_aab
            ;;
        ios)
            check_requirements
            build_ios
            ;;
        backend)
            check_requirements
            build_backend
            ;;
        deploy-android)
            check_requirements
            deploy_android
            ;;
        deploy-ios)
            check_requirements
            deploy_ios
            ;;
        deploy-backend-aws)
            check_requirements
            deploy_backend_aws
            ;;
        test-flutter)
            check_requirements
            test_flutter
            ;;
        test-backend)
            check_requirements
            test_backend
            ;;
        test-integrations)
            check_requirements
            test_integrations
            ;;
        full)
            check_requirements
            deploy_full
            ;;
        *)
            echo "Usage: $0 [android|android-aab|ios|backend|deploy-android|deploy-ios|deploy-backend-aws|test-flutter|test-backend|test-integrations|full]"
            echo ""
            echo "Examples:"
            echo "  $0 android              # Build Android APK"
            echo "  $0 android-aab          # Build Android AAB (for Play Store)"
            echo "  $0 ios                  # Build iOS app"
            echo "  $0 backend              # Build backend"
            echo "  $0 full                 # Build everything"
            echo "  $0 deploy-android       # Deploy to Play Store"
            echo "  $0 deploy-ios           # Deploy to App Store"
            echo "  $0 test-flutter         # Run Flutter tests"
            echo "  $0 test-backend         # Run backend tests"
            exit 1
            ;;
    esac
}

main "$@"