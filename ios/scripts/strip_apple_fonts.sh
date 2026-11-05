#!/bin/sh
# Removes bundled SF Pro files from the iOS app. Android still ships them.
# This phase must run after Flutter's "Run Script" and before "Thin Binary",
# so the copy that gets embedded is already stripped.
set -eu

framework="${BUILT_PRODUCTS_DIR:-}/App.framework"
if [ ! -d "$framework" ]; then
  echo "error: App.framework was not found at ${framework}." >&2
  echo "error: Strip Apple Fonts must run after the Flutter Run Script phase." >&2
  exit 1
fi

remove_sf_fonts() {
  font_dir="$1"
  if [ ! -d "$font_dir" ]; then
    return 0
  fi
  for font in "$font_dir"/*; do
    [ -f "$font" ] || continue
    case "$(basename "$font")" in
      [Ss][Ff][Pp][Rr][Oo]*)
        echo "Removing Apple font: $font"
        rm -f "$font"
        ;;
    esac
  done
}

remove_sf_fonts "${framework}/flutter_assets/assets/fonts"

embedded="${TARGET_BUILD_DIR:-}/${FRAMEWORKS_FOLDER_PATH:-}/App.framework/flutter_assets/assets/fonts"
remove_sf_fonts "$embedded"
