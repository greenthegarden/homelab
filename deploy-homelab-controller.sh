#!/usr/bin/env bash

log_info()  { echo -e "\033[0;32m[INFO]\033[0m  $1"; }
log_warn()  { echo -e "\033[1;33m[WARN]\033[0m  $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; }

readonly BIN_PATH=".venv/bin"

if [[ ! -d ${BIN_PATH} ]]; then
  log_error "${BIN_PATH} directory not found"
  exit 1
fi

readonly ANSIBLE_BIN="${BIN_PATH}/ansible"
readonly ANSIBLE_GALAXY_BIN="${BIN_PATH}/ansible-galaxy"
readonly ANSIBLE_PLAYBOOK_BIN="${BIN_PATH}/ansible-playbook"

log_info "Using $(${ANSIBLE_BIN} --version)"

${ANSIBLE_GALAXY_BIN} install -r requirements.yaml

${ANSIBLE_PLAYBOOK_BIN} --inventory inventory-homelab_lxc.yaml --vault-password-file vault.pass playbooks/homelab-controller.yaml
