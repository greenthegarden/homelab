#!/usr/bin/env bash

# Based on https://github.com/ralish/bash-script-template/blob/main/template.sh

# Enable xtrace if the DEBUG environment variable is set
if [[ ${DEBUG-} =~ ^1|yes|true$ ]]; then
    set -o xtrace       # Trace the execution of the script (debug)
fi

# Only enable these shell behaviours if we're not being sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
    # A better class of script...
    set -o errexit      # Exit on most errors (see the manual)
    set -o nounset      # Disallow expansion of unset variables
    set -o pipefail     # Use last non-zero exit code in a pipeline
fi

# Enable errtrace or the error trap handler will not work as expected
set -o errtrace         # Ensure the error trap handler is inherited


PYTHON_VERSION=3.11

# R='\033[0;31m'   #'0;31' is Red's ANSI color code
# G='\033[0;32m'   #'0;32' is Green's ANSI color code
# Y='\033[1;32m'   #'1;32' is Yellow's ANSI color code
# B='\033[0;34m'   #'0;34' is Blue's ANSI color code

INFO='\033[0;36m'   #'0;36' is Cyan's ANSI color code
NC='\033[0m'     # No Color

echo -e "${INFO} Updating system packages...${NC}"
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
    wget -O ansible/proxmox.py \
    https://github.com/xezpeleta/Ansible-Proxmox-inventory/raw/master/proxmox.py
fi
