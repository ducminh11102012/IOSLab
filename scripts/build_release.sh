#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[ioslab-build] %s\n' "$1"
}

fail() {
  printf '[ioslab-build] ERROR: %s\n' "$1" >&2
  exit 1
}

REPO_URL="${1:-}"
WORKDIR="${2:-}"
IOSLAB_SIMULATOR_MOCK="${IOSLAB_SIMULATOR_MOCK:-false}"

if [[ -n "$REPO_URL" ]]; then
  TARGET_DIR="${WORKDIR:-$(mktemp -d)}"
  log "Cloning repository: $REPO_URL -> $TARGET_DIR"
  git clone "$REPO_URL" "$TARGET_DIR"
  ROOT_DIR="$TARGET_DIR"
else
  ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
fi

DIST_DIR="$ROOT_DIR/dist"
PROJECT_PATH="$ROOT_DIR/macos-app/IOSLabDashboard.xcodeproj"
SCHEME_NAME="IOSLabDashboard"
mkdir -p "$DIST_DIR"

log "Using root directory: $ROOT_DIR"
log "IOSLAB_SIMULATOR_MOCK=$IOSLAB_SIMULATOR_MOCK"

log "Installing backend dependencies"
(
  cd "$ROOT_DIR/backend"
  npm ci
  log "Building backend"
  npm run build
)

log "Installing CLI dependencies"
(
  cd "$ROOT_DIR/cli"
  npm ci
  log "Building CLI"
  npm run build
)

log "Validating macOS/Xcode environment"
if [[ "$(uname -s)" != "Darwin" ]]; then
  fail "This dashboard build requires macOS (uname -s returned $(uname -s))"
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  fail "xcodebuild not found on this machine"
fi

if [[ ! -d "$PROJECT_PATH" ]]; then
  fail "Expected project file not found at macos-app/IOSLabDashboard.xcodeproj"
fi

if [[ ! -f "$PROJECT_PATH/project.pbxproj" ]]; then
  fail "Project exists but project.pbxproj is missing at macos-app/IOSLabDashboard.xcodeproj/project.pbxproj"
fi

log "Building dashboard with xcodebuild (scheme: $SCHEME_NAME)"
(
  cd "$ROOT_DIR/macos-app"
  xcodebuild \
    -project IOSLabDashboard.xcodeproj \
    -scheme "$SCHEME_NAME" \
    -configuration Release \
    -derivedDataPath .build/release \
    build
)

APP_PATH="$ROOT_DIR/macos-app/.build/release/Build/Products/Release/IOSLabDashboard.app"
if [[ ! -d "$APP_PATH" ]]; then
  fail "xcodebuild completed but expected app bundle is missing at $APP_PATH"
fi

log "Packaging dashboard app bundle"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$DIST_DIR/IOSLabDashboard.zip"

log "Build artifacts generated in: $DIST_DIR"
ls -lah "$DIST_DIR"
