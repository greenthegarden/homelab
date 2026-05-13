#!/usr/bin/env bash

# set -o verbose # Echo all commands before execution

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

log_info()    { echo -e "${GREEN}[INFO]${NF} $1"; }
log_success() { echo -e "${BLUE_BOLD}[SUCCESS]${NF} $1"; }
log_warn()    { echo -e "${YELLOW_BOLD}[WARN]${NF} $1"; }
log_error()   { echo -e "${RED_BOLD}[ERROR]${NF} $1" >&2; }

readonly DOCKER_VOLUME_BACKUP_IMAGE="offen/docker-volume-backup:v2.48.0"

usage () {
    echo "Usage: $(basename "${0}") [-v] [-f folder] [-c container] volumes ..."
    echo
    echo "Options:"
    echo "  -v            Enable verbose output"
    echo "  -f folder     Local folder to store backups"
    echo "  -c container  Container that uses volumes"
    exit 1
}

# Default vars
VERBOSE=false

function parse_args {
    # if [[ $# -lt 2 ]]; then
    #     log_error "Illegal number of arguments provided"
    #     usage
    #     exit 2
    # fi
    while getopts :f:c:vh option ; do
        case "${option}" in
            f)
                folder=${OPTARG}
                log_info "Processing option 'f' with '${OPTARG}' argument"
                ;;
            c)
                container=${OPTARG}
                log_info "Processing option 'c' with '${OPTARG}' argument"
                ;;
            v)
                VERBOSE=true
                log_info "Processing option 'v'"
                ;;
            h)
                log_info "Processing option 'h'"
                usage
                ;;
            :)
                log_error "Option requires an argument."
                usage
                ;;
            ?)
                log_error "Invalid option: -$OPTARG"
                usage
                ;;
            *)
                log_error "Unknown option  -$OPTARG"
                usage
                ;;
        esac
    done

    shift $((OPTIND - 1))

    if [ $# -eq 0 ]; then
        log_error "Error: No volumes specified" >&2
        usage
    fi

    # Convert the remainder of the arguments to an array
    # of volumes
    declare -g -a volumes=("$@")

    # Define folder as concatenation of folder and
    # container args
    declare -g folder=${folder}'/'${container}

    if [ "$VERBOSE" = true ]; then
        log_info "Running script $0 with"
        log_info "  Verbose: ON"
        log_info "  Folder: ${folder}"
        log_info "  Container: ${container}"
        log_info "  $# Volumes: ${volumes[*]}"
        echo
    fi
}

function stop_container {
    log_info "Stopping container ${container}"
    docker stop "${container}"
}

function start_container {
    log_info "Starting container ${container}"
    docker start "${container}"
}

function create_backup_folder {
    log_info "Creating folder for backups at ${folder}"
    mkdir -p "${folder}"
}

function remove_backup_folder {
    log_info "Removing folder for backups at ${folder}"
    rm -rf "${folder}"
}

function list_files_in_dir {
    log_info "Files in directory ${folder}"
    ls -al "${folder}"
}

function create_backup_from_volume {
    docker run --rm \
        --env BACKUP_FILENAME="backup-${volume}-%Y-%m-%dT%H-%M-%S.tar.gz" \
        --env BACKUP_FILENAME_EXPAND="true" \
        --entrypoint backup \
        -v "${volume}":/backup/"${volume}":ro \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v "${folder}"/:/archive/ \
        "${DOCKER_VOLUME_BACKUP_IMAGE}"
    # If error occurs remove backup folder and restart container
    trap 'remove_backup_folder' ERR
    trap 'start_container' ERR
}

function check_docker_volume_exists {
    # this does not work as returns partial matches
    result=$(docker volume ls -f name="${volume}" --format "{{.Name}}")
    if [[ ! "${result}" == "${volume}" ]]; then
        log_error "Docker volume ${volume} not found"
        start_container
        remove_backup_folder
        exit 1
    else
        log_info "Docker volume ${volume} exists"
    fi
}

function loop_volumes {
    # log_info "Looping through volumes ${volumes[*]}"
    for volume in "${volumes[@]}" ; do
        check_docker_volume_exists
        log_info "Creating backup for volume ${volume}"
        create_backup_from_volume
    done
}

function main {
    # Set variables based on arguments provided
    parse_args "$@"
    echo

    # Create a local folder to contain the backups
    create_backup_folder
    echo

    # Stop the relevant container
    stop_container
    echo

    # Process volumes
    loop_volumes
    echo

    # Restart container
    start_container
    echo

    # Show created files
    list_files_in_dir
    echo
}

# Script execution starts here
main "$@"
