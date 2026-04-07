#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE_NAME="${1:-iPhone 17 Pro}"
BUNDLE_ID="com.xcodeyang.XYDebugViewDemo"
DERIVED_DATA_DIR="/tmp/XYDebugViewDemoDerivedData"
OUTPUT_DIR="$ROOT_DIR/docs/images"

find_device_id() {
  xcrun simctl list devices available | awk -F '[()]' -v device_name="$DEVICE_NAME" '
    $0 ~ device_name {
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^[0-9A-F-]{36}$/) {
          print $i
          exit
        }
      }
    }
  '
}

launch_and_wait() {
  local device_id="$1"
  shift
  xcrun simctl terminate "$device_id" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch "$device_id" "$BUNDLE_ID" "$@" >/dev/null
}

capture() {
  local device_id="$1"
  local file_path="$2"
  xcrun simctl io "$device_id" screenshot "$file_path" >/dev/null
}

DEVICE_ID="$(find_device_id)"
if [[ -z "$DEVICE_ID" ]]; then
  echo "Unable to find simulator device: $DEVICE_NAME" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

"$ROOT_DIR/scripts/bootstrap_demo.sh"

xcrun simctl boot "$DEVICE_ID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$DEVICE_ID" -b
xcrun simctl ui "$DEVICE_ID" appearance light >/dev/null 2>&1 || true
xcrun simctl status_bar "$DEVICE_ID" override \
  --time "21:39" \
  --dataNetwork wifi \
  --wifiBars 3 \
  --cellularMode notSupported \
  --batteryState charged \
  --batteryLevel 100 >/dev/null 2>&1 || true

xcodebuild \
  -workspace "$ROOT_DIR/Demo/XYDebugViewDemo.xcworkspace" \
  -scheme XYDebugViewDemo \
  -configuration Debug \
  -destination "id=$DEVICE_ID" \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  build \
  CODE_SIGNING_ALLOWED=NO >/dev/null

APP_PATH="$DERIVED_DATA_DIR/Build/Products/Debug-iphonesimulator/XYDebugViewDemo.app"
xcrun simctl install "$DEVICE_ID" "$APP_PATH" >/dev/null

launch_and_wait "$DEVICE_ID"
sleep 2
capture "$DEVICE_ID" "$OUTPUT_DIR/demo-home.png"

launch_and_wait "$DEVICE_ID" -XYDemoAutoShowCard3D YES
sleep 3
capture "$DEVICE_ID" "$OUTPUT_DIR/demo-card-3d.png"

launch_and_wait "$DEVICE_ID" -XYDemoAutoShowCard3D YES -XYDemoAutoOpenControls YES
sleep 4
capture "$DEVICE_ID" "$OUTPUT_DIR/demo-card-3d-controls.png"

xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl status_bar "$DEVICE_ID" clear >/dev/null 2>&1 || true

echo "Saved screenshots to $OUTPUT_DIR"
