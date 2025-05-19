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
B='\033[0;34m'   #'0;34' is Blue's ANSI color code
NC='\033[0m'     # No Color

INFO="[${B}INFO${NC}]"
# ERROR="[${R}ERROR${NC}]"


echo -e "Running script: ${B}$(basename "$0")${NC}"
echo -e "Running in directory: ${B}$(pwd)${NC}"
echo -e "Running on host: ${B}$(hostname)${NC}"
echo -e "Running on OS: ${B}$(lsb_release -d | cut -f2)${NC}"
echo -e "Running on kernel: ${B}$(uname -r)${NC}"
echo -e "Running on architecture: ${B}$(uname -m)${NC}"
# shellcheck disable=SC2116,SC2086
echo -e "Running on shell: ${B}$(echo $SHELL)${NC}"
echo -e "Running on shell version: ${B}$(bash --version | head -n 1)${NC}"
echo -e "Running on shell options: ${B}$(shopt)${NC}"
echo -e "Running on shell options: ${B}$(set | grep -E 'DEBUG|PS1|PS2|PS4')${NC}"
echo -e "Running on shell options: ${B}$(set | grep -E 'BASH|BASH_VERSION|BASH_ENV')${NC}"
echo -e "Running on shell options: ${B}$(set | grep -E 'PROMPT_COMMAND|PS4')${NC}"



echo -e "${INFO} Updating system packages...${NC}"
apt update && apt -y upgrade


# install pip and pipx
apt install -y python3-pip python${PYTHON_VERSION}-venv pipx python3-passlib

# configure pipx
python3 -m pipx ensurepath

python_app_modules=(
    ansible
    docker
    jmespath
    pre-commit
    yamllint
    ansible-lint
)

# now use pipx to install the defined modules
for module in "${python_app_modules[@]}"; do
    pipx install --include-deps "$module"
done

# apply any upgrades
pipx upgrade-all

# install git hook scripts
pre-commit install --hook-type pre-commit --hook-type pre-push
pre-commit autoupdate

# # Get Proxmox dynamic inventory plugin
# # needs the ansible module to run
# python3 -m pip install --user --break-system-packages ansible
# if [ ! -f ansible/proxmox.py ]; then
#     wget -O ansible/proxmox.py \
#     https://github.com/xezpeleta/Ansible-Proxmox-inventory/raw/master/proxmox.py
# fi
