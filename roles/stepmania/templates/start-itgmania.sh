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

IFS="
"
sleep 2

# remove logs before starting ITGmania, just in case we don't accidentally
# shut down in some corner case.
rm -f "/home/mckyla/.itgmania/Logs/info.txt"

# reset music and visual offsets
# was -22ms
sed -i 's/GlobalOffsetSeconds=.*/GlobalOffsetSeconds=-0\.020000/g' /home/mckyla/.itgmania/Save/Preferences.ini
sed -i 's/VisualDelaySeconds=.*/VisualDelaySeconds=0\.000000/g' /home/mckyla/.itgmania/Save/Preferences.ini

# wait 5 seconds for network interface then mount NAS to Songs, LocalProfiles and Courses
sudo sleep 5

# unmount first, if there have been changes to the mount paths since the last run
(sudo umount /home/mckyla/stepmania-content/Songs) || true
(sudo umount /home/mckyla/.itgmania/Save/LocalProfiles) || true
(sudo umount /home/mckyla/stepmania-content/Courses) || true

# mount additional content from NAS
sudo mount -t nfs 192.168.11.3:/volume1/Songs /home/mckyla/stepmania-content/Songs
sudo mount -t nfs 192.168.11.3:/volume1/LocalProfiles /home/mckyla/.itgmania/Save/LocalProfiles/
sudo mount -t nfs 192.168.11.3:/volume1/Courses /home/mckyla/stepmania-content/Courses

# wait 5 seconds to give time for the DAC drivers to load
sudo sleep 5

/opt/itgmania/itgmania

if [[ $? -ne 0 ]]; then
  # wait until enter is pressed
  read -p "Press enter to continue"
elif grep -q "5b5c513e-7067-4a14-89de-1fa007d93a33" "/home/mckyla/.itgmania/Logs/info.txt"; then
  # Above is magic string inserted to logs by stepmania theme if "power off" is selected.
  sudo poweroff
fi
