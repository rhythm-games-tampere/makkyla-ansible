# McKyla Ansible

Ansible configuration management for McKyla Superarcade — ITGmania-based dance game arcade cabinets.

## Prerequisites

- Ansible installed on the control machine
- SSH access to the target hosts

## Inventory

The inventory at `inventories/makkyla/hosts` defines three machines in the `dedicab` group: `pro2`, `fat2`, and `ten2`. Each host has per-host variables for audio devices, USB port mappings, and display devices.

## Provisioning

Run the full install playbook to apply all roles (`grub`, `ssh`, `utils`, `graphics`, `stepmania`, `analog-dance-pad`):

```bash
ansible-playbook -K -i inventories/makkyla full-install.yml --diff --limit <host>
```

* `--diff` is to list all changes
* `--ask-become-pass` is to prompt for sudo password

Replace `<host>` with a specific host name (e.g. `pro2`) or use `dedicab` to target all machines.

The first run generates initial ITGmania config files. After a reboot, run the playbook again to apply the full configuration.
