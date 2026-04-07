#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEMO_DIR="${ROOT_DIR}/Demo"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "error: xcodegen is required. Install it with 'brew install xcodegen'." >&2
  exit 1
fi

if ! command -v pod >/dev/null 2>&1; then
  echo "error: CocoaPods is required. Install it before generating the demo workspace." >&2
  exit 1
fi

cd "${DEMO_DIR}"
rm -rf Pods Podfile.lock *.xcworkspace *.xcodeproj
xcodegen generate --spec project.yml
pod install

echo "Generated ${DEMO_DIR}/XYDebugViewDemo.xcworkspace"
