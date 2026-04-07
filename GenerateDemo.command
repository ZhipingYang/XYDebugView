#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "Repository: ${ROOT_DIR}"
echo "Generating XYDebugView demo..."
echo

if "${ROOT_DIR}/scripts/bootstrap_demo.sh"; then
  echo
  echo "Demo generated successfully."
  open "${ROOT_DIR}/Demo/XYDebugViewDemo.xcworkspace"
else
  echo
  echo "Demo generation failed." >&2
  exit 1
fi

echo
if [[ -t 0 ]]; then
  read -r -p "Press Enter to close..."
fi
