#!/bin/bash

trap 'xset +dpms; xset s on' EXIT

# disable sleeps
xset -dpms
xset s off

# try to clone displays for streaming – but if it's not possible for some reason, that's fine as well
xrandr --output 'HDMI-A-0' --mode 1920x1080 --scale 1x1 --rate 120 --panning 0x0

# remove logs before starting ITGmania, just in case we don't accidentally
# shut down in some corner case.
rm -f "/home/mckyla/.itgmania/Logs/info.txt"

# reset settings
cp /home/mckyla/Preferences-standard.ini /home/mckyla/.itgmania/Save/Preferences.ini
cp /home/mckyla/ThemePrefs-standard.ini /home/mckyla/.itgmania/Save/ThemePrefs.ini

# Configure PipeWire audio output
AUDIO_SINK_PATTERN="usb"     # regex matched against the sink's card/node name
AUDIO_SINK_EXCLUDE="hdmi"    # regex matched against the node name

find_audio_sink() {
  pw-dump 2>/dev/null | jq -r --arg pat "$AUDIO_SINK_PATTERN" --arg excl "$AUDIO_SINK_EXCLUDE" '
    [ .[]
      | select(.type == "PipeWire:Interface:Node")
      | select(.info.props["media.class"] == "Audio/Sink")
      | select(.info.props["node.name"] // "" | test($excl; "i") | not)
      | select(
          (.info.props["alsa.card_name"]     // "" | test($pat; "i")) or
          (.info.props["api.alsa.card.name"] // "" | test($pat; "i")) or
          (.info.props["node.name"]          // "" | test($pat; "i")) )
      | "\(.id) \(.info.props["node.name"])"
    ] | first // empty'
}

read -r AUDIO_SINK_ID AUDIO_SINK_NAME <<< "$(find_audio_sink)"
if [[ -n "$AUDIO_SINK_NAME" ]]; then
  echo "Audio sink: $AUDIO_SINK_NAME (id $AUDIO_SINK_ID)"
  wpctl set-default "$AUDIO_SINK_ID" || true
else
  echo "WARNING: no PipeWire sink matching '$AUDIO_SINK_PATTERN', keeping the current default sink" >&2
fi

pw-jack /opt/itgmania/itgmania

if [[ $? -ne 0 ]]; then
  # wait until enter is pressed
  read -p "Press enter to continue"
elif grep -q "5b5c513e-7067-4a14-89de-1fa007d93a33" "/home/mckyla/.itgmania/Logs/info.txt"; then
  # Above is magic string inserted to logs by stepmania theme if "power off" is selected.
  sudo poweroff
fi
