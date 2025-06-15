#!/bin/sh

while ($true); do
  ms=$(printf "%.0f\n" $(jc ping -c 1 1.1.1.1 | jq "(.round_trip_ms_avg)"))
  busctl --user call rs.i3status /ping rs.i3status.custom SetIcon s net_loopback
  if [ $ms = "null" ]; then
    busctl --user call rs.i3status /ping rs.i3status.custom SetText ss down down
    busctl --user call rs.i3status /ping rs.i3status.custom SetState s critical
  else
    busctl --user call rs.i3status /ping rs.i3status.custom SetText ss "$ms"ms "$ms"ms
    if [ $(echo "$ms > 30" | bc) -eq 1 ]; then
      busctl --user call rs.i3status /ping rs.i3status.custom SetState s warning
    elif [ $(echo "$ms > 60" | bc) -eq 1 ]; then
      busctl --user call rs.i3status /ping rs.i3status.custom SetState s critical
    else
      busctl --user call rs.i3status /ping rs.i3status.custom SetState s idle
    fi
  fi
  sleep 2
done
