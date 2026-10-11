#!/bin/bash
# Autostarted at desktop login. OBS rewrites its ini files on exit, so restore
# the Ansible-managed config on every start.

CONFIG_SRC=/home/mckyla/obs-config
CONFIG_DST=/home/mckyla/.config/obs-studio

mkdir -p "$CONFIG_DST"
cp -r "$CONFIG_SRC/." "$CONFIG_DST/"

# Cabs are powered off without waiting for OBS. Leftover files make OBS block on a safe mode dialog.
rm -f "$CONFIG_DST"/.sentinel/run_*

exec obs --minimize-to-tray --collection makkyla --profile makkyla
