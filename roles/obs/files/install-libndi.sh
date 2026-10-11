#!/bin/bash
# Installs libndi from the NDI SDK into /usr/local/lib (after DistroAV's CI/libndi-get.sh).
# Usage: install-libndi.sh <sdk-url> <work-dir>
set -euo pipefail

SDK_URL="$1"
WORK_DIR="$2"

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

if [ ! -d "$WORK_DIR/ndisdk" ]; then
  curl -fsSL --retry 5 -o ndi-sdk.tar.gz "$SDK_URL"
  tar -xzf ndi-sdk.tar.gz
  # Accepts the NDI SDK license. `yes` gets SIGPIPE when the installer exits; ignore it.
  installer=$(ls Install_NDI_SDK_*_Linux.sh)
  (yes || true) | PAGER=cat sh "./$installer" > /dev/null
  mv "NDI SDK for Linux" ndisdk
  rm -f ndi-sdk.tar.gz "$installer"
fi

libdir="$WORK_DIR/ndisdk/lib/$(uname -m)-linux-gnu"
if [ ! -d "$libdir" ]; then
  echo "No NDI libraries for $(uname -m) in $WORK_DIR/ndisdk/lib" >&2
  exit 1
fi

cp -P "$libdir"/libndi* /usr/local/lib/
ldconfig
