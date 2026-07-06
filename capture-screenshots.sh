#!/usr/bin/env bash
#
# Capture README screenshots from the running demo using headless Chrome.
# No npm / dependencies needed — it drives your locally-installed Chrome or Chromium.
#
# Usage:   ./capture-screenshots.sh
# Custom:  CHROME="/path/to/chrome" ./capture-screenshots.sh
#
set -euo pipefail

# --- locate a Chrome/Chromium binary ---
CHROME="${CHROME:-}"
if [ -z "$CHROME" ]; then
  for c in google-chrome google-chrome-stable chromium chromium-browser microsoft-edge; do
    if command -v "$c" >/dev/null 2>&1; then CHROME="$c"; break; fi
  done
fi
# macOS default locations
if [ -z "$CHROME" ]; then
  for m in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
           "/Applications/Chromium.app/Contents/MacOS/Chromium" \
           "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"; do
    if [ -x "$m" ]; then CHROME="$m"; break; fi
  done
fi
if [ -z "$CHROME" ]; then
  echo "Could not find Chrome/Chromium/Edge. Install one, or run:"
  echo "  CHROME=/path/to/chrome ./capture-screenshots.sh"
  exit 1
fi
echo "Using browser: $CHROME"

DIR="$(cd "$(dirname "$0")" && pwd)"
FILE="file://$DIR/index.html"
mkdir -p "$DIR/docs"

shot() {  # shot <output.png> <hash>
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
            --force-device-scale-factor=2 --window-size=1440,1024 \
            --virtual-time-budget=3000 \
            --screenshot="$DIR/docs/$1" "$FILE#$2" >/dev/null 2>&1
  echo "  ✓ docs/$1"
}

echo "Capturing screenshots into docs/ ..."
shot "dashboard.png"             "user=1&view=dashboard"
shot "manager-agent.png"         "user=4&view=manager"
shot "engagement-heatmap.png"    "user=1&view=engagement&tab=heatmap"
shot "ai-insights.png"           "user=1&view=aiinsights"
shot "compensation-sandbox.png"  "user=1&view=comp&tab=reviews"
shot "pay-equity.png"            "user=1&view=comp&tab=equity"
shot "org-directory.png"         "user=1&view=directory"
shot "contact-card.png"          "user=1&view=directory&contact=8"
shot "guided-tour.png"           "tour=0&step=1"
echo "Done. See the docs/ folder."
