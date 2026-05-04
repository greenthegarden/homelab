#!/usr/bin/env bash

# -e: Exit on error
# -u: Exit if a variable is undefined
# -o pipefail: Prvent errors in a pipeline from being masked
set -euo pipefail


# ============= Helper Functions =============
#

log_info()  { echo -e "\033[0;32m[INFO]\033[0m  $1"; }
log_warn()  { echo -e "\033[1;33m[WARN]\033[0m  $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; }

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
PLAYBOOK_FILE="playbooks/homelab-controller.yaml"


# ============= Main Functions =============
#

function ansible_install_dependencies {
  check_file_exists ${REQUIREMENTS_FILE}
  check_executable_exists ${ANSIBLE_GALAXY_BIN}
  log_info "Installing Ansible dependencies from ${REQUIREMENTS_FILE}"
  ${ANSIBLE_GALAXY_BIN} install -r ${REQUIREMENTS_FILE}
}

function ansible_run_playbook {
  check_executable_exists ${ANSIBLE_PLAYBOOK_BIN}
  check_file_exists ${INVENTORY_FILE}
  check_file_exists ${VAULT_FILE}
  check_file_exists ${PLAYBOOK_FILE}
  log_info "Running Ansible Playbook ${PLAYBOOK_FILE}"
  # ${ANSIBLE_PLAYBOOK_BIN} \
  #   --inventory ${INVENTORY_FILE} \
  #   --vault-password-file ${VAULT_FILE} \
  #   ${PLAYBOOK_FILE}
}

function main {
  check_executable_exists ${ANSIBLE_BIN}
  log_info "Using $(${ANSIBLE_BIN} --version)"
  ansible_install_dependencies
  ansible_run_playbook
}


# ============= Script Execution =============
#

main
