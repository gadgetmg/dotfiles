#!/bin/sh

# Download latest Bing wallpaper
json=$(curl "https://www.bing.com/HPImageArchive.aspx?format=js&n=1&mkt=engUS")
urlbase=$(jq -r ".images[0].urlbase" <<< $json)
url="https://www.bing.com${urlbase}_UHD.jpg"
wget $url -O ~/OneDrive/Wallpapers/Bing\ Images/${url:31}

# Find the most recent Bing wallpaper image in local cache
wallpaper=$(find ~/OneDrive/Wallpapers/Bing\ Images -type f | tail -n 1)
echo $wallpaper

# Kill and rerun swaybg with new image
current=$(pgrep swaybg)
swaymsg exec "swaybg -m fill -i \"$wallpaper\""
if [ -n "$current" ]; then
  sleep 1
  kill $current
fi
