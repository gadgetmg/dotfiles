usage() {
  echo "Usage: $0 [-d wallpaperdir -f]"
  echo ""
  echo "Options:"
  echo "  -d wallpaperdir   Directory to download wallpapers"
  echo "  -f                Force downloading, even if the latest wallpaper exists"
  exit 1
}

force=false
wallpaperdir=~/Pictures/Spotlight

while getopts "d:f" opt; do
  case "${opt}" in
  d) wallpaperdir="$OPTARG" ;;
  f) force=true ;;
  *) usage ;;
  esac
done

tempFile=$(mktemp)
# Scrape the home page
if curl "https://windows10spotlight.com" --fail -so "$tempFile"; then
  # Look for the link to the first image page
  url=$(grep -oP 'https://windows10spotlight.com/images/[0-9]*' "$tempFile" | head -1)
fi
rm "$tempFile"

echo "Latest image: $url"
tempFile=$(mktemp)
if curl "$url" --fail -so "$tempFile"; then
  # Parse the first h1 as the name
  title=$(grep -oP '<h1>\K.*?(?=</h1>)' "$tempFile" | head -1)
  # Parse the date
  date=$(grep -oP '<span class="date">\K.*?(?=</span>)' "$tempFile" | head -1)
  # Parse the links to raw images
  readarray -t images < <(grep -oP 'href="\Khttps://windows10spotlight\.com/wp-content/uploads/[0-9]{4}/[0-9]{1,2}/[0-9a-f]{32}\.jpg' "$tempFile")
  rm "$tempFile"

  if $force || [ ! -f """$wallpaperdir""/Landscape/$title.jpg" ]; then
    echo "Downloading \"$title\" (Landscape)"
    mkdir -p "$wallpaperdir"/Landscape
    if curl "${images[0]}" --fail -so """$wallpaperdir""/Landscape/$title.jpg"; then
      touch -cd "$date" """$wallpaperdir""/Landscape/$title.jpg"
    fi
  fi
  if $force || [ ! -f """$wallpaperdir""/Portrait/$title.jpg" ]; then
    echo "Downloading \"$title\" (Portrait)"
    mkdir -p "$wallpaperdir"/Portrait
    if curl "${images[1]}" --fail -so """$wallpaperdir""/Portrait/$title.jpg"; then
      touch -cd "$date" """$wallpaperdir""/Portrait/$title.jpg"
    fi
  fi
fi

# Set the appropriately oriented background on each monitor with swaybg
readarray -t outputs < <(swaymsg -t get_outputs -r | jq -c ".[]")
for output in "${outputs[@]}"; do
  name=$(echo "$output" | jq -r '.name')
  width=$(echo "$output" | jq -r '.rect.width')
  height=$(echo "$output" | jq -r '.rect.height')

  if ((width > height)); then
    wallpaper=$(readlink -f "$wallpaperdir"/Landscape/"$title".jpg)
  else
    wallpaper=$(readlink -f "$wallpaperdir"/Portrait/"$title".jpg)
  fi

  # Kill and rerun swaybg with new image
  current=$(pgrep -f "swaybg -o $name")
  swaymsg exec "swaybg -o $name -m fill -i \"""$wallpaper""\""
  if [ -n "$current" ]; then
    sleep 1
    kill "$current"
  fi
done
