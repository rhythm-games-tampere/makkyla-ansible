#!/bin/bash

trap 'xset +dpms; xset s on' EXIT

# disable sleeps
xset -dpms
xset s off

# try to clone displays for streaming – but if it's not possible for some reason, that's fine as well
(
  xrandr --output 'HDMI-A-0' --mode 1920x1080 --scale 1x1 --rate 120 --panning 0x0
# xrandr --output 'HDMI-A-0' --mode 1920x1080 --scale 1x1 --rate 120 --panning 0x0 --output 'DisplayPort-0' --same-as 'HDMI-0' --mode 1280x720 --scale-from 1920x1080
# xrandr --output 'HDMI-0' --mode 1920x1080 --scale 1x1 --rate 120 --panning 0x0
# xrandr --output HDMI-0 --off --output "DVI-D-0" --panning 0x0 &&
# xrandr --output HDMI-0 --same-as "DVI-D-0" --mode 1280x720 --scale-from 1920x1080
) || true

# remove logs before starting ITGmania, just in case we don't accidentally
# shut down in some corner case.
rm -f "/home/mckyla/.itgmania/Logs/info.txt"

# reset settings
cp /home/mckyla/Preferences-standard.ini /home/mckyla/.itgmania/Save/Preferences.ini
cp /home/mckyla/ThemePrefs-standard.ini /home/mckyla/.itgmania/Save/ThemePrefs.ini

/opt/itgmania/itgmania

if [[ $? -ne 0 ]]; then
  # wait until enter is pressed
  read -p "Press enter to continue"
elif grep -q "5b5c513e-7067-4a14-89de-1fa007d93a33" "/home/mckyla/.itgmania/Logs/info.txt"; then
  # Above is magic string inserted to logs by stepmania theme if "power off" is selected.
  sudo poweroff
fi
