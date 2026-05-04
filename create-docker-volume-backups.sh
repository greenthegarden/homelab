#!/usr/bin/env bash

# set -o verbose # Echo all commands before execution

# -e: Exit on error
# -u: Exit if a variable is undefined
# -o pipefail: Prvent errors in a pipeline from being masked
set -eEou pipefail

log_info()  { echo -e "\033[0;32m[INFO]\033[0m  $1"; }
log_warn()  { echo -e "\033[1;33m[WARN]\033[0m  $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; }

readonly DOCKER_VOLUME_BACKUP_IMAGE="offen/docker-volume-backup"
readonly DOCKER_VOLUME_BACKUP_TAG="v2.48.0"

usage () {
    echo "Usage: $0 [-v] [-f folder] [-c container] volumes ..."
    echo ""
    echo "Options:"
    echo "  -v            Enable verbose output"
    echo "  -f folder     Local folder to store backups"
    echo "  -c container  Container that uses volumes"
    exit 1
}

function parse_args {
  if [[ $# -lt 2 ]]; then
      log_error "Illegal number of arguments provided"
      usage
      exit 2
  fi
  while getopts f:c:v option
  do
      case "${option}" in
          f) folder=${OPTARG} ;;
          c) container=${OPTARG} ;;
          v) VERBOSE=true ;;
          \?) log_error "Invalid option: -$OPTARG" usage;;
      esac
  done

  shift $((OPTIND - 1))

  if [ $# -eq 0 ]; then
      log_error "Error: No volumes specified" >&2
      usage
  fi

  volumes=$@

  if [ "$VERBOSE" = true ]; then
      log_info "Running script $0 with"
      log_info "  Verbose: ON"
      log_info "  Folder: ${folder:-stdout}"
      log_info "  Container: ${container}"
      log_info "  Volumes: $@"
      log_info ""
  fi
}

function stop_container {
  log_info "Stopping container ${container}"
  docker stop ${container}
}

function start_container {
  log_info "Starting container ${container}"
  docker start ${container}
}

function create_backup_folder {
  log_info "Creating folder for backups at ${folder}"
  mkdir -p ${folder}
}

function remove_backup_folder {
  log_info "Removing folder for backups at ${folder}"
  rm -rf ${folder}
}

function create_backup_from_volume {
  docker run --rm \
    --env BACKUP_FILENAME="backup-${volume}-%Y-%m-%dT%H-%M-%S.tar.gz" \
    --env BACKUP_FILENAME_EXPAND="true" \
    --entrypoint backup \
    -v ${volume}:/backup/${volume}:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v ${folder}/:/archive/ \
    ${DOCKER_VOLUME_BACKUP_IMAGE}:${DOCKER_VOLUME_BACKUP_TAG}
  # If error occures remove backup folder
  trap 'remove_backup_folder' ERR
  trap 'start_container' ERR
}

function check_docker_volume_exists {
  # this does not work as returns partial matches
  result=$(docker volume ls -f name=${volume} --format "{{.Name}}")
  if [[ ! ${result} == ${volume} ]]; then
    log_error "Docker volume ${volume} not found"
    start_container
    remove_backup_folder
    exit 1
  fi
}

function loop_volumes {
  for volume in "${volumes[@]}";
  do
    check_docker_volume_exists
    log_info "Creating backup for volume ${volume}"
    create_backup_from_volume
  done
}

function main {
  parse_args "$@"
  create_backup_folder ${folder}
  stop_container ${container}
  loop_volumes ${volumes}
  start_container ${container}
}

# Exectution starts here
main "$@"
