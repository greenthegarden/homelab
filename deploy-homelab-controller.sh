#!/usr/bin/env bash

# -e: Exit on error
# -u: Exit if a variable is undefined
# -o pipefail: Prvent errors in a pipeline from being masked
set -euo pipefail


# ============= Utility Variables =============
#

readonly RED="\033[0;31m"
readonly GREEN="\033[0;32m"
readonly YELLOW="\033[1;33m"
readonly BLUE="\033[1;34m"
readonly NC="\033[0m" # No colour


# ============= Helper Functions =============
#


log_info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
log_success() { echo -e "${BLUE}[SUCCESS]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

function check_file_exists {
  file=$1
  if [[ ! -f ${file} ]]; then
    log_error "File ${file} not found"
    exit 1
  fi
}

function check_executable_exists {
  executable=$1
  if [[ ! -x ${executable} ]]; then
    log_error "Executable ${executable} not found"
    exit 1
  fi
}

function check_directory_exists {
  directory=$1
  if [[ ! -d ${directory} ]]; then
    log_error "Directory ${directory} not found"
    exit 1
  fi
}


# ============= Variables =============
#

readonly BIN_PATH=".venv/bin"
check_directory_exists ${BIN_PATH}
readonly ANSIBLE_BIN="${BIN_PATH}/ansible"
readonly ANSIBLE_GALAXY_BIN="${BIN_PATH}/ansible-galaxy"
readonly ANSIBLE_PLAYBOOK_BIN="${BIN_PATH}/ansible-playbook"

REQUIREMENTS_FILE="requirements.yaml"
INVENTORY_FILE="inventory-homelab_lxc.yaml"
VAULT_FILE="vault.pass"
PLAYBOOK_FILE="playbooks/deploy-stack-controller.yaml"


# ============= Main Functions =============
#

function uv_update {
  uv self update
}

function uv_upgrade_dependencies {
  uv sync --upgrade
}

function ansible_info {
  check_executable_exists ${ANSIBLE_BIN}
  log_info "Using $(${ANSIBLE_BIN} --version)"
}

function ansible_install_dependencies {
  check_file_exists ${REQUIREMENTS_FILE}
  check_executable_exists ${ANSIBLE_GALAXY_BIN}
  log_info "Installing Ansible dependencies from ${REQUIREMENTS_FILE}"
  ${ANSIBLE_GALAXY_BIN} install -r ${REQUIREMENTS_FILE}
  log_success "Ansible dependencies installed"
}

function ansible_run_playbook {
  check_executable_exists ${ANSIBLE_PLAYBOOK_BIN}
  check_file_exists ${INVENTORY_FILE}
  check_file_exists ${VAULT_FILE}
  check_file_exists ${PLAYBOOK_FILE}
  log_info "Running Ansible Playbook ${PLAYBOOK_FILE}"
  ${ANSIBLE_PLAYBOOK_BIN} \
    --inventory ${INVENTORY_FILE} \
    --vault-password-file ${VAULT_FILE} \
    ${PLAYBOOK_FILE}
  log_success "Playbook ${PLAYBOOK_FILE} run"
}

function main {
  # Start message
  log_info "Running ${0} to deploy Homelab controller"
  echo

  # Update uv and dependencies
  uv_update
  uv_upgrade_dependencies

  # Ansible version info
  ansible_info
  echo

  # Install dependencies via Ansible Glaxaxy
  ansible_install_dependencies
  echo

  # Run playbook
  ansible_run_playbook
  echo
}


# ============= Script Execution =============
#

main
