#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[ioslab-build] %s\n' "$1"
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

log "Building dashboard"
if command -v xcodebuild >/dev/null 2>&1 && [[ "$(uname -s)" == "Darwin" ]] && [[ -f "$ROOT_DIR/macos-app/IOSLabDashboard.xcodeproj/project.pbxproj" ]]; then
  (
    cd "$ROOT_DIR/macos-app"
    xcodebuild -project IOSLabDashboard.xcodeproj -scheme IOSLabDashboard -configuration Release -derivedDataPath .build/release
  )

  APP_PATH="$ROOT_DIR/macos-app/.build/release/Build/Products/Release/IOSLabDashboard.app"
  if [[ -d "$APP_PATH" ]]; then
    log "Packaging dashboard app bundle"
    ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$DIST_DIR/IOSLabDashboard.zip"
  else
    log "Expected app bundle not found; creating fallback zip from dashboard sources"
    (
      cd "$ROOT_DIR/macos-app"
      zip -r "$DIST_DIR/IOSLabDashboard.zip" IOSLabDashboard >/dev/null
    )
  fi
else
  log "xcodebuild project unavailable in this environment; running swift package build fallback"
  (
    cd "$ROOT_DIR/macos-app"
    swift build
    zip -r "$DIST_DIR/IOSLabDashboard.zip" IOSLabDashboard >/dev/null
  )
fi

log "Build artifacts generated in: $DIST_DIR"
ls -lah "$DIST_DIR"
