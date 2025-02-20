#!/usr/bin/env bash

PYTHON_VERSION=3.11

# ensure base system packages are all up-to-date
apt update && apt -y upgrade

# install pipx
apt install -y python3-pip python${PYTHON_VERSION}-venv pipx

# install base python modules
python3 -m pipx ensurepath

python_modules=(
  ansible
  docker
  passlib
  jmespath
  pre-commit
  yamllint
  ansible-lint
)

# now use pipx to install the defined modules
for module in "${python_modules[@]}"; do
  pipx install --include-deps "$module"
done

# apply any upgrades
pipx upgrade-all

# install git hook scripts
pre-commit install --hook-type pre-commit --hook-type pre-push
pre-commit autoupdate

# Get Proxmox dynamic inventory plugin
# needs the ansible module to run
python3 -m pip install --user --break-system-packages ansible
if [ ! -f ansible/proxmox.py ]; then
  wget -O ansible/proxmox.py https://github.com/xezpeleta/Ansible-Proxmox-inventory/raw/master/proxmox.py
fi
