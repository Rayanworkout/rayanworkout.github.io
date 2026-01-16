#!/usr/bin/env bash
set -euo pipefail

POSTS_DIR="_posts"
TODAY="$(date +%F)"   # YYYY-MM-DD

shopt -s nullglob
files=("$POSTS_DIR"/*.md "$POSTS_DIR"/*.markdown)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No .md/.markdown files found in $POSTS_DIR/"
  exit 0
fi

for f in "${files[@]}"; do
  base="$(basename "$f")"

  # Skip if already has YYYY-MM-DD- prefix
  if [[ "$base" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}- ]]; then
    echo "SKIP (already dated): $base"
    continue
  fi

  # Create a slug from the filename (without extension)
  name="${base%.*}"
  ext="${base##*.}"

  # Lowercase, replace spaces/underscores with hyphens, drop non-url chars, collapse hyphens
  slug="$(printf "%s" "$name" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[[:space:]_]+/-/g; s/[^a-z0-9-]+//g; s/-+/-/g; s/^-+//; s/-+$//')"

  newbase="${TODAY}-${slug}.${ext}"
  newpath="${POSTS_DIR}/${newbase}"

  # Avoid overwriting: add -2, -3, ... if needed
  if [[ -e "$newpath" ]]; then
    n=2
    while [[ -e "${POSTS_DIR}/${TODAY}-${slug}-${n}.${ext}" ]]; do
      n=$((n+1))
    done
    newbase="${TODAY}-${slug}-${n}.${ext}"
    newpath="${POSTS_DIR}/${newbase}"
  fi

  mv -v -- "$f" "$newpath"
done

echo "Done. Renamed posts with today's date: $TODAY"
