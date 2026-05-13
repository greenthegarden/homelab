#!/usr/bin/env bash

#
# Script Name: setup_host.sh
# Description: This script sets up a host .
# Author: Philip Cutler
# Date: 2026-04-11
# Version: 1.0
#
# Usage:
#   ./setup_host.sh
#
# Parameters:
#   None
#
# Exit Status:
#   0 - Success
#   1 - Failure
#
# Example:
#   To execute the script, simply run:
#   ./setup_host.sh
#
# Notes:
#   uv commands
#
#   'uv self update' <= update version of uv
#   'uv lock --check' <= check if the lockfile is up-to-date
#   'uv lock --upgrade' <= upgrade all packages

# Based on https://github.com/ralish/bash-script-template/blob/main/template.sh

# Use shellcheck for static analysis.

# ============= Utility Variables =============
#

readonly NF="\033[0m" # No format
readonly BOLD="\033[1m"
readonly RED_BOLD="\033[1;31m"
readonly GREEN="\033[0;32m"
readonly YELLOW_BOLD="\033[1;33m"
readonly BLUE_BOLD="\033[1;34m"

# ============= Helper Functions =============
#

log_info()    { echo -e "${GREEN}[INFO]${NF} $1"; }
log_success() { echo -e "${BLUE_BOLD}[SUCCESS]${NF} $1"; }
log_warn()    { echo -e "${YELLOW_BOLD}[WARN]${NF} $1"; }
log_error()   { echo -e "${RED_BOLD}[ERROR]${NF} $1" >&2; }

die() {
    log_error "$*"
    exit 1
}

check_command () {
    command -v "$1" >/dev/null 2>&1
}

need_command () {
    if ! check_command "$1";
    then
        die "Required command $1 not found"
    fi
}

display_system_env () {
    log_info "Environment details..."
    log_info "Running script: ${BOLD}$(basename "$0")"
    log_info "Running in directory: ${BOLD}$(pwd)"
    log_info "Running on host: ${BOLD}$(hostname)"
    log_info "Running on OS: ${BOLD}$(cat /etc/os-release | grep -E '^(PRETTY_NAME)')"
    log_info "Running on kernel: ${BOLD}$(uname -r)"
    log_info "Running on architecture: ${BOLD}$(uname -m)"
    # shellcheck disable=SC2116,SC2086
    log_info "Running on shell: ${BOLD}$(echo $SHELL)"
    log_info "Running on shell version: ${BOLD}$(bash --version | head -n 1)"
    # log_info "Running on shell options: ${B}$(shopt)"
    # log_info "Running on shell options: ${B}$(set | grep -E 'DEBUG|PS1|PS2|PS4')"
    # log_info "Running on shell options: ${B}$(set | grep -E 'BASH|BASH_VERSION|BASH_ENV')"
    # log_info "Running on shell options: ${B}$(set | grep -E 'PROMPT_COMMAND|PS4')"
    log_info "PATH is set to: ${BOLD}${PATH}"
}

update_system () {
    log_info 'Updating system packages...'
    apt update && apt -y upgrade
}

set_path () {
    if [[ ":${PATH}:" != *":${INSTALL_DIR}:"* ]]; then
        log_warn "${INSTALL_DIR} is not in PATH"
        export PATH="${INSTALL_DIR}:${PATH}"
        log_info "Added ${INSTALL_DIR} to current session PATH"
        log_info "PATH: ${PATH}"

        echo "export PATH=\"${INSTALL_DIR}:\${PATH}\"" >> "${BASHRC_FILE}"
        log_info "Added ${INSTALL_DIR} to PATH in ${BASHRC_FILE}"
    else
        log_info "${INSTALL_DIR} already in current session PATH"
    fi
}

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


# ============= Main Variables =============
#
readonly BASHRC_FILE=${HOME}/.bashrc
readonly INSTALL_DIR=${HOME}/.local/bin

parse_args() {
    # parse CLI flags
    while getopts "vh" opt; do
        case $opt in
            v) echo "Verbose mode enabled" ;;
            h) echo "Usage: $0 [-v] [-h]"; exit 0 ;;
            *) echo "Not a valid option"; exit 0 ;;
        esac
    done
}

install_packages () {
    log_info "Installing required packages..."
    apt install -y \
        curl \
        git
}

install_packages_dev () {
    log_info "Installing dev packages..."
    apt install -y \
        curl \
        git \
        software-properties-common \
        apt-transport-https \
        ca-certificates
}

install_oh_my_zsh () {
    # https://ohmyz.sh/
    if [ ! -d "${HOME}/.oh-my-zsh" ]; then
        log_info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    else
        log_warn "oh-my-zsh is already installed."
    fi
}

# # install zsh plugins
# if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
#     echo -e "${INFO} Installing zsh-autosuggestions plugin...${NC}"

uv_install () {
    # https://docs.astral.sh/uv/getting-started/installation/
    if ! command -v uv &> /dev/null; then
        log_info "Installing uv ..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        log_warn "uv is already installed."
        log_info "Updating uv ..."
        uv self update
    fi
}

uv_install_dependencies () {
    uv sync
}

uv_update_dependencies () {
    uv lock --upgrade
}

install_prek () {
    PREK_VERSION=v0.3.13
    curl --proto '=https' --tlsv1.2 -LsSf https://github.com/j178/prek/releases/download/${PREK_VERSION}/prek-installer.sh | sh
    prek install -f
}

update_prek () {
    prek self update
}

pre_commit_update () {
    prek auto-update
    prek cache gc
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

add_aliases_to_zshrc () {
    ZSHRC="${HOME}/.zshrc"
    if ! grep -q "alias uvx=" "${ZSHRC}"; then
        log_info "Adding aliases to .zshrc..."
        {
            echo "alias ansible='uvx --from ansible-core ansible'"
            echo "alias ansible-lint='uvx --from ansible-lint ansible-lint'"
            echo "alias ansible-playbook='uvx --from ansible-core ansible-playbook'"
            echo "alias ansible-galaxy='uvx --from ansible-core ansible-galaxy'"
        } >> "$ZSHRC"
        log_info "Aliases added to .zshrc."
    else
        log_warn "Aliases already exist in .zshrc."
    fi
}

source_zshrc_to_apply_changes () {
    ZSHRC="${HOME}/.zshrc"
    if [[ -f "$ZSHRC" ]]; then
        log_info "Sourcing ${ZSHRC} to apply changes..."
        # shellcheck source=${HOME}/.zshrc
        # shellcheck disable=SC1090
        # shellcheck disable=SC1091
        source "$ZSHRC"
    else
        log_warn "${ZSHRC} not found, skipping sourcing."
    fi
}

print_final_message () {
    log_success "Development dependencies installed successfully!"
}

main() {
    # Start message
    log_info "Running ${0} to configure Homelab controller"
    echo

    parse_args "$@"

    display_system_env
    echo

    set_path
    echo

    update_system
    echo

    install_packages
    echo

    # install_uv

    print_final_message
    echo
}

# Execution starts here
main "$@"
