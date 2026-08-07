#!/bin/bash
#
# Convert curated project screenshots to WebP at 1200px wide.
#
#   bash tool/convert_screenshots.sh
#
# Requires cwebp:  brew install webp libtiff
#
# Reads full-resolution sources from assets/_src/screenshots/<folder>/ and
# writes NN_name.webp into assets/images/projects/<folder>/.
#
# [RULE] Sources live under assets/_src/, which is deliberately NOT declared
# in pubspec.yaml. Folder declarations bundle every file in the folder, so a
# source PNG sitting next to its .webp would ship to every visitor and undo
# the conversion entirely.
#
# Adding a screenshot: drop the source in assets/_src/screenshots/<folder>/,
# add a MAP line below, re-run, then add the gallery entry to the project's
# assets/data/projects/<slug>.json.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO/assets/_src/screenshots"
OUT="$REPO/assets/images/projects"
Q=82
W=1200

# "<src-dir>|<src-file>|<out-name>"
MAP=$(cat <<'EOF'
masr_alkher|splash.png|01_splash
masr_alkher|dashboard.png|02_dashboard
masr_alkher|asign_cases.png|03_assigned_cases
masr_alkher|case_data.png|04_case_data
masr_alkher|form.png|05_form
yafleet|splash.png|01_splash
yafleet|home.png|02_home
yafleet|new_trip.png|03_new_trip
yafleet|new_shipment.png|04_new_shipment
yafleet|shipment.png|05_shipment
yafleet|chat.png|06_chat
motary|splash.png|01_splash
motary|home.png|02_home
motary|product_details.png|03_product_details
motary|cart.png|04_cart
motary|seller_home.png|05_seller_home
motary|seller_add_new_product.png|06_seller_add_product
qanony|splash.PNG|01_splash
qanony|home(1).PNG|02_home
qanony|service_details.PNG|03_service_details
qanony|request_details.PNG|04_request_details
qanony|document_wallet.PNG|05_document_wallet
qanony|profile.PNG|06_profile
itutor|splash.PNG|01_splash
itutor|library.PNG|02_library
itutor|tools.PNG|03_tools
itutor|chat.PNG|04_chat
itutor|voice_chat.PNG|05_voice_chat
itutor|subscription.PNG|06_subscription
EOF
)

command -v cwebp >/dev/null || {
  echo "cwebp not found. Install it with: brew install webp libtiff" >&2
  exit 2
}

ok=0; fail=0
while IFS='|' read -r dir src out; do
  [ -z "$dir" ] && continue
  in="$SRC/$dir/$src"
  dst="$OUT/$dir/$out.webp"
  if [ ! -f "$in" ]; then
    echo "MISSING: $in"; fail=$((fail+1)); continue
  fi
  mkdir -p "$OUT/$dir"
  if cwebp -quiet -q $Q -resize $W 0 "$in" -o "$dst" 2>/dev/null; then
    printf "%-28s %6s -> %6s  %s\n" "$out.webp" \
      "$(du -h "$in" | cut -f1)" "$(du -h "$dst" | cut -f1)" "$dir"
    ok=$((ok+1))
  else
    echo "FAILED: $in"; fail=$((fail+1))
  fi
done <<< "$MAP"

echo ""
echo "converted=$ok failed=$fail"
