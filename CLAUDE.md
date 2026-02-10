# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ansible configuration management for **McKylän Superarcade** — a set of custom ITGmania-based dance game arcade cabinets. Manages three machines (`pro2`, `fat2`, `ten2`) in the `dedicab` group, each with per-host variables for audio devices, USB port mappings, and display devices. The machines are accessed as the `mckyla` user. The host operating system is Ubuntu Studio.

## Common Commands

```bash
# Full install (always use --limit to target a specific machine)
ansible-playbook -i inventories/makkyla full-install.yml --diff --limit <host>

# Target all machines
ansible-playbook -i inventories/makkyla full-install.yml --diff --limit dedicab
```

## Architecture

### Playbook

- **full-install.yml** — Main (and only) playbook. Runs all roles with `become: true`.

### Role Execution Order (full-install)

`grub` → `ssh` → `utils` → `graphics` → `stepmania` → `analog-dance-pad`

### Key Roles

| Role | Purpose |
|------|---------|
| **grub** | Kernel params: disables CPU mitigations, sets USB HID polling rates (1ms joystick, 10ms mouse/keyboard) |
| **ssh** | Authorized keys (Alhetus, quvide) from GitHub |
| **utils** | Base packages (vim, htop, rsync, git), disables auto-updates/suspend/hibernate, passwordless sudo |
| **graphics** | AMD GPU drivers (firmware-amd-graphics, Mesa, xserver-xorg-video-amdgpu), X.org DPI config |
| **stepmania** | Builds ITGmania from custom `rhythm-games-tampere/itgmania` repo using CMake, installs Simply Love theme, configures Preferences.ini and keymaps |
| **analog-dance-pad** | udev rules, Node.js pad server, teensy_loader_cli, systemd service |

There is also a **gcc** role (installs gcc/g++) that exists but is not currently included in `full-install.yml`.

### Per-Host Configuration

Each machine in `inventories/makkyla/hosts` defines: `audio_device`, `main_display_device`, `left_pad_usb_port`, `right_pad_usb_port`.

### Important Paths on Target Machines

- `/opt/itgmania/` — Game binary (built from source)
- `/opt/analog-dance-pad/` — Pad server
- `/home/mckyla/stepmania-content/` — Songs, Courses, Themes (Simply Love)
- `/home/mckyla/.itgmania/Save/` — Preferences.ini, Keymaps.ini
- `/home/mckyla/.itgmania/Logs/` — Game logs

## Key Design Details

- **Joystick detection**: `start.sh` template scans `/sys/class/input` and matches USB port topology to physical pad locations to assign correct joystick indices in Keymaps.ini.
- **HDMI cloning**: `start.sh` attempts display cloning via xrandr for streaming (clones `main_display_device` to HDMI-0), with fallback.
- **Power-off trigger**: A magic UUID string in ITGmania logs triggers `sudo poweroff`.
- **Systemd service**: `analog-dance-pad` runs as a systemd unit with auto-restart.
- **CMake build**: ITGmania is built with CMake (`cmake -B Build`, then `cmake --build Build --parallel`).
