# McKylä Ansible

Ansible configuration management for McKyla Superarcade.
The playbook can be used to setup a fresh Ubuntu install from scratch,
and is ran on existing setups regularly to apply updated configuration and update the game.


## Prerequisites

- Ansible installed on the control machine
- SSH access to the target hosts


## Provisioning

Unless overriding something, just run:

```bash
./deploy.py --all
```

To limit to a single host:

```bash
./deploy.py --limit pro
```


## Testing

A Podman-based test environment runs the playbook in a disposable container, skipping hardware and systemd tasks:

```bash
cd test && bash run-test.sh
```

This connects to an existing test container (or creates one if needed), 
and runs `full-install.yml` with `--skip-tags hardware,systemd`.
Use `--rebuild` to force a fresh container, or `--cleanup` to remove it afterwards.
