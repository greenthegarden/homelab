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

# R='\033[0;31m'   #'0;31' is Red's ANSI color code
# G='\033[0;32m'   #'0;32' is Green's ANSI color code
# Y='\033[1;33m'   #'1;33' is Yellow's ANSI color code
B='\033[0;34m'   #'0;34' is Blue's ANSI color code
NC='\033[0m'     # No Color

INFO="[${B}INFO${NC}]"
# ERROR="[${R}ERROR${NC}]"

display_system_env () {
    echo -e "Running script: ${B}$(basename "$0")${NC}"
    echo -e "Running in directory: ${B}$(pwd)${NC}"
    echo -e "Running on host: ${B}$(hostname)${NC}"
    echo -e "Running on OS: ${B}$(lsb_release -d | cut -f2)${NC}"
    echo -e "Running on kernel: ${B}$(uname -r)${NC}"
    echo -e "Running on architecture: ${B}$(uname -m)${NC}"
    # shellcheck disable=SC2116,SC2086
    echo -e "Running on shell: ${B}$(echo $SHELL)${NC}"
    echo -e "Running on shell version: ${B}$(bash --version | head -n 1)${NC}"
    # echo -e "Running on shell options: ${B}$(shopt)${NC}"
    # echo -e "Running on shell options: ${B}$(set | grep -E 'DEBUG|PS1|PS2|PS4')${NC}"
    # echo -e "Running on shell options: ${B}$(set | grep -E 'BASH|BASH_VERSION|BASH_ENV')${NC}"
    # echo -e "Running on shell options: ${B}$(set | grep -E 'PROMPT_COMMAND|PS4')${NC}"
}

update_system () {
    echo -e "${INFO} Updating system packages...${NC}"
    apt update && apt -y upgrade
}

install_packages () {
# install required packages
echo -e "${INFO} Installing required packages...${NC}"
apt install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    htop \
    jq \
    tree \
    unzip \
    zip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    ncdu \
    zsh \
    bash-completion \
    autojump \
    fonts-powerline
}

install_oh_my_zsh () {
    # https://ohmyz.sh/
    if [ ! -d "${HOME}/.oh-my-zsh" ]; then
        echo -e "${INFO} Installing oh-my-zsh...${NC}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    else
        echo -e "${INFO} oh-my-zsh is already installed.${NC}"
    fi
}

# # install zsh plugins
# if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
#     echo -e "${INFO} Installing zsh-autosuggestions plugin...${NC}"

install_uv () {
    # https://docs.astral.sh/uv/getting-started/installation/
    if ! command -v uvx &> /dev/null; then
        echo -e "${INFO} Installing uv...${NC}"
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        echo -e "${INFO} uv is already installed.${NC}"
        uv self update
    fi
}

create_local_bin () {
    mkdir -p "${HOME}/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
    # export UVX_HOME="$HOME/.local/share/uvx"
    # export UVX_CACHE="$HOME/.cache/uvx"
    # export UVX_CONFIG="$HOME/.config/uvx"
}

install_python () {
    PYTHON_VERSION=3.14
    # install PYTHON_VERSION
    if ! uv python list | grep -q "python@${PYTHON_VERSION}"; then
        echo -e "${INFO} Installing Python ${PYTHON_VERSION} via uv...${NC}"
        uv python install ${PYTHON_VERSION}
    else
        echo -e "${INFO} Upgrading Python installations.${NC}"
        uv python upgrade
    fi
}

install_ansible_via_uv () {
    # install ansible and ansible-lint via uv
    uv tool install --python ${PYTHON_VERSION} --with-executables-from ansible-core,ansible-lint ansible
}

install_prec () {
    PREK_VERSION=v0.3.3
    curl --proto '=https' --tlsv1.2 -LsSf https://github.com/j178/prek/releases/download/${PREK_VERSION}/prek-installer.sh | sh
}

install_pre_commit () {
    # Install prec (as replacement for pre-commit)
    # https://adamj.eu/tech/2025/05/07/pre-commit-install-uv/
    uv tool install --python ${PYTHON_VERSION} pre-commit --with pre-commit-uv
}

pre_commit_update () {
    prek auto-update
    prek cache gc
}

upgrade_uv_tools () {
    # Upgrade tools
    uv tool upgrade --all
}

install_git_hook_scripts () {
    uvx --from pre-commit pre-commit install --hook-type pre-commit --hook-type pre-push
    uvx --from pre-commit pre-commit autoupdate
}

clean_pre_commit () {
    # Run pre-commit gc to clean up old hooks
    uvx --from pre-commit pre-commit gc
}

# # Get Proxmox dynamic inventory plugin
# # needs the ansible module to run
# python3 -m pip install --user --break-system-packages ansible
# if [ ! -f ansible/proxmox.py ]; then
#     wget -O ansible/proxmox.py \
#     https://github.com/xezpeleta/Ansible-Proxmox-inventory/raw/master/proxmox.py
# fi

# use ncdu to check disk usage
# echo -e "${INFO} Checking disk usage with ncdu...${NC}"
# ncdu --exclude .cache --exclude .local --exclude .config --exclude .vscode

# uninstalled autopep8! ✨ 🌟 ✨
# uninstalled jmespath! ✨ 🌟 ✨
# uninstalled requests! ✨ 🌟 ✨
# uninstalled pylint! ✨ 🌟 ✨
# uninstalled ansible-lint! ✨ 🌟 ✨
# uninstalled docker! ✨ 🌟 ✨
# uninstalled flake8! ✨ 🌟 ✨
# uninstalled yamllint! ✨ 🌟 ✨
# uninstalled pycodestyle! ✨ 🌟 ✨
# uninstalled molecule! ✨ 🌟 ✨
# uninstalled black! ✨ 🌟 ✨

add_aliases_to_zshrc () {
    # add aliases to .zshrc
    ZSHRC="$HOME/.zshrc"
    if ! grep -q "alias uvx=" "$ZSHRC"; then
        echo -e "${INFO} Adding aliases to .zshrc...${NC}"
        {
            echo "alias ansible='uvx --from ansible-core ansible'"
            echo "alias ansible-lint='uvx --from ansible-lint ansible-lint'"
            echo "alias ansible-playbook='uvx --from ansible-core ansible-playbook'"
            echo "alias pre-commit='uvx --from pre-commit-uv pre-commit'"
        } >> "$ZSHRC"
        echo -e "${INFO} Aliases added to .zshrc.${NC}"
    else
        echo -e "${INFO} Aliases already exist in .zshrc.${NC}"
    fi
}


source_zshrc_to_apply_changes () {
    if [[ -f "$ZSHRC" ]]; then
        echo -e "${INFO} Sourcing .zshrc to apply changes...${NC}"
        # shellcheck source=${HOME}/.zshrc
        # shellcheck disable=SC1090
        # shellcheck disable=SC1091
        source "$ZSHRC"
    else
        echo -e "${INFO} .zshrc not found, skipping sourcing.${NC}"
    fi
}

print_final_message () {
    echo -e "${INFO} Development dependencies installed successfully!${NC}"
}

# Run components
display_system_env
update_system
install_packages
install_oh_my_zsh
install_uv
create_local_bin
install_python
install_ansible_via_uv
install_prec
pre_commit_update
