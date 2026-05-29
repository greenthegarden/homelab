#!/usr/bin/env bash

# -e: Exit on error
# -u: Exit if a variable is undefined
# -o pipefail: Prvent errors in a pipeline from being masked
set -euo pipefail


# ============= Utility Variables =============
#

readonly NF="\033[0m" # No format
# readonly BOLD="\033[1m"
readonly RED_BOLD="\033[1;31m"
readonly GREEN="\033[0;32m"
readonly YELLOW_BOLD="\033[1;33m"
readonly BLUE_BOLD="\033[1;34m"

# ============= Helper Functions =============
#

print_info()    { printf "  ${GREEN}[INFO]${NF} %s\n" "$*"; }
print_success() { printf "  ${BLUE_BOLD}[SUCCESS]${NF} %s\n" "$*"; }
print_warn()    { printf "  ${YELLOW_BOLD}[WARN]${NF} %s\n" "$*"; }
print_error()   { printf "  ${RED_BOLD}[ERROR]${NF} %s\n" "$*" >&2; }

function check_file_exists {
    file="$1"
    if [[ ! -f "${file}" ]]; then
        print_error "File ${file} not found"
        exit 1
    fi
}

function check_executable_exists {
    executable="$1"
    if [[ ! -x "${executable}" ]]; then
        print_error "Executable ${executable} not found"
        exit 1
    fi
}

function check_directory_exists {
    directory="$1"
    if [[ ! -d "${directory}" ]]; then
        print_error "Directory ${directory} not found"
        exit 1
    fi
}


# ============= Variables =============
#

readonly BIN_PATH=".venv/bin"
check_directory_exists "${BIN_PATH}"
readonly ANSIBLE_BIN="${BIN_PATH}/ansible"
readonly ANSIBLE_GALAXY_BIN="${BIN_PATH}/ansible-galaxy"
readonly ANSIBLE_PLAYBOOK_BIN="${BIN_PATH}/ansible-playbook"

REQUIREMENTS_FILE="requirements.yaml"
INVENTORY_FILE="inventory-homelab_lxc.yaml"
VAULT_FILE="vault.pass"
PLAYBOOK_FILE="playbooks/deploy-stack-controller.yaml"


# ============= Main Functions =============
#
function parse_args {
    # parse CLI flags
    while getopts "p:fvh" opt ; do
        case "${opt}" in
            p)  PLAYBOOK_FILE="${OPTARG}"
                print_info "Running playbook '${OPTARG}'"
                ;;
            f)  print_info "Getting facts"
                ansible_print_facts
                exit 0
                ;;
            v)  print_info "Getting hostvars"
                ansible_print_hostvars
                exit 0
                ;;
            h)  print_success "Usage: $0 [-p 'playbook'] [-f] [-v] [-h]"; exit 0 ;;
            *)  print_error "Not a valid option"; exit 1 ;;
        esac
    done
}


function uv_update {
    uv self update
}

function uv_upgrade_dependencies {
    uv sync --upgrade
}

function ansible_info {
    check_executable_exists "${ANSIBLE_BIN}"
    print_info "Using $(${ANSIBLE_BIN} --version)"
}

function ansible_install_dependencies {
    check_file_exists "${REQUIREMENTS_FILE}"
    check_executable_exists "${ANSIBLE_GALAXY_BIN}"
    print_info "Installing Ansible dependencies from ${REQUIREMENTS_FILE}"
    "${ANSIBLE_GALAXY_BIN}" install -r "${REQUIREMENTS_FILE}"
    print_success "Ansible dependencies installed"
}

function ansible_print_facts {
    check_executable_exists "${ANSIBLE_PLAYBOOK_BIN}"
    check_file_exists "${INVENTORY_FILE}"
    check_file_exists "${VAULT_FILE}"
    print_info "Gettng Ansible facts"
    "${ANSIBLE_BIN}" \
        --inventory "${INVENTORY_FILE}" \
        --vault-password-file "${VAULT_FILE}" \
        "$(hostname)" \
        -m ansible.builtin.setup
}

function ansible_print_hostvars {
    check_executable_exists "${ANSIBLE_PLAYBOOK_BIN}"
    check_file_exists "${INVENTORY_FILE}"
    check_file_exists "${VAULT_FILE}"
    print_info "Gettng Ansible hostvars"
    "${ANSIBLE_BIN}" \
        --inventory "${INVENTORY_FILE}" \
        --vault-password-file "${VAULT_FILE}" \
        "$(hostname)" \
        -m ansible.builtin.debug -a "var=hostvars['$(hostname)']"
}

function ansible_run_playbook {
    check_executable_exists "${ANSIBLE_PLAYBOOK_BIN}"
    check_file_exists "${INVENTORY_FILE}"
    check_file_exists "${VAULT_FILE}"
    check_file_exists "${PLAYBOOK_FILE}"
    print_info "Running Ansible Playbook ${PLAYBOOK_FILE}"
    "${ANSIBLE_PLAYBOOK_BIN}" \
        --inventory "${INVENTORY_FILE}" \
        --vault-password-file "${VAULT_FILE}" \
        "${PLAYBOOK_FILE}"
    print_success "Playbook ${PLAYBOOK_FILE} run"
}

function main {
    # Start message
    print_info "Running ${0} to deploy Homelab controller"
    echo

    # Parse any arguments
    parse_args "$@"

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

# Execution starts here
main "$@"
