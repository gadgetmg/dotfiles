#!/bin/sh
systemctl --user add-wants default.target mpd.service
systemctl --user add-wants mpd.service mpDris2.service
systemctl --user add-wants sway-session.target waybar.service mako.service wallpaper.service foot-server.socket
