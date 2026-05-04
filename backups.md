# Creating Backups

Use `offen/docker-volume-backup` to create volume backups using [documentation](https://offen.github.io/docker-volume-backup/how-tos/restore-volumes-from-backup.html).

To manually create a backup use

```bash
docker run --rm \
  -v data:/backup/data \
  --entrypoint backup \
  offen/docker-volume-backup:v2
```

```bash
function create_backups {
  # Make local directory for backups
  BACK_UP_DIR="${HOME}/one-off-backups"
  mkdir -p ${BACK_UP_DIR}
  # Stop container
  if [ ! -z ${CONTAINER+x} ]
  then
    echo CONTAINER variable not set
    exit 1
  fi
  docker stop ${CONTAINER}
  # Create backups
  if [ ! -z ${VOLUMES_TO_BACKUP+x} ]
  then
    echo VOLUMES_TO_BACKUP variable not set
    exit 1
  fi
  out = $(declare -p VOLUMES_TO_BACKUP 2>/dev/null)
  if [ ! $out == declare\ -a* ]
  then
    echo VOLUMES_TO_BACKUP variable is not an array
    exit 1
  fi
  for volume in "${VOLUMES_TO_BACKUP[@]}";
  do
    docker run --rm \
      --env BACKUP_FILENAME="backup-${volume}-%Y-%m-%dT%H-%M-%S.tar.gz" \
      --env BACKUP_FILENAME_EXPAND="true" \
      --entrypoint backup \
      -v ${volume}:/backup/${volume}:ro \
      -v /var/run/docker.sock:/var/run/docker.sock:ro \
      -v ${BACK_UP_DIR}/:/archive/ \
      offen/docker-volume-backup:v2.48.0
  done
  # Restart container
  docker start ${CONTAINER}
}

## Service Specific

### Tududi

```bash
# Define variables
CONTAINER="affine"
VOLUMES_TO_BACKUP=("tududi_data" "tududi_uploads")
create_backups
create-docker-volume-backups.sh
```

### AFFiNE

```bash
# Define variables
readonly BACK_UP_DIR="${HOME}/one-off-backups"
CONTAINER="affine"
VOLUMES_TO_BACKUP=("affine-config" "affine-upload")
# Make local directory for backups
mkdir -p ${BACK_UP_DIR}
# Stop container
docker stop ${CONTAINER}
# Create backups
for volume in "${VOLUMES_TO_BACKUP[@]}";
do
  docker run --rm \
    --env BACKUP_FILENAME="backup-${volume}-%Y-%m-%dT%H-%M-%S.tar.gz" \
    --env BACKUP_FILENAME_EXPAND="true" \
    --entrypoint backup \
    -v ${volume}:/backup/${volume}:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v ${BACK_UP_DIR}/:/archive/ \
    offen/docker-volume-backup:v2.48.0
done
# Restart container
docker start ${CONTAINER}
```

### Beszel Agent

```bash
mkdir ${HOME}/archive
docker stop beszel-agent
docker run --rm \
  --env BACKUP_FILENAME="backup-beszel-agent-%Y-%m-%dT%H-%M-%S.tar.gz" \
  --env BACKUP_FILENAME_EXPAND="true" \
  --entrypoint backup \
  -v beszel-agent:/backup/beszel-agent-backup:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v ${HOME}/archive:/archive \
  offen/docker-volume-backup:v2.48.0
```

Can check the contents of the archived file using, for example

```
tar -tvf ${HOME}/archive/backup-beszel-agent-2026-05-02T12-34-57.tar.gz
```

To [restore from a backup](https://offen.github.io/docker-volume-backup/how-tos/restore-volumes-from-backup.html)

* Stop the container(s) that are using the volume
* Untar the backup you want to restore

  ```bash
  tar -C /tmp -xvf  backup.tar.gz
  ```

* Using a temporary once-off container, mount the volume (the example assumes it’s named data) and copy over the backup. Make sure you copy the correct path level (this depends on how you mount your volume into the backup container), you might need to strip some leading elements

  ```bash
  docker run -d --name temp_restore_container -v data:/backup_restore alpine
  docker cp /tmp/backup/data-backup temp_restore_container:/backup_restore
  docker stop temp_restore_container
  docker rm temp_restore_container
  ```
* Restart the container(s) that are using the volume

For example, to restore Tududi volumes

```bash
# Stop existing container which will use volume
docker stop tududi
# Extract tududi_data backup to /tmp
tar -C /tmp -xvf  backup-tududi_data-2026-05-02T12-50-44.tar.gz
# Extract tududi_uploads backup to /tmp
tar -C /tmp -xvf  backup-tududi_uploads-2026-05-02T12-50-44.tar.gz
# Ensure all files have correct uid:gid
chown -R root:root /tmp/backup
# Create temporary container with destination volumes mounted
docker run -d --name temp_restore_container -v tududi_data:/tududi_data_backup_restore -v tududi_uploads:/tududi_uploads_backup_restore alpine
# Copy local files to destination volume within temporary container keeping uid:gid
docker cp -a /tmp/backup/tududi_data/. temp_restore_container:/tududi_data_backup_restore
docker cp -a /tmp/backup/tududi_uploads/. temp_restore_container:/tududi_uploads_backup_restore
# Check contents of destination volumes
docker run --rm -it -v tududi_data:/volume alpine /bin/sh
docker run --rm -it -v tududi_uploads:/volume alpine /bin/sh
# Stop and remove temporary container
docker stop temp_restore_container
docker rm temp_restore_container
# Restart Tududi
docker start tududi
```

For example, to restore AFFiNE volumes

```bash
# Stop existing container which will use volume
docker stop affine
# Extract tududi_data backup to /tmp
tar -C /tmp -xvf  backup-tududi_data-2026-05-02T12-50-44.tar.gz
# Extract tududi_uploads backup to /tmp
tar -C /tmp -xvf  backup-tududi_uploads-2026-05-02T12-50-44.tar.gz
# Ensure all files have correct uid:gid
chown -R root:root /tmp/backup
# Create temporary container with destination volumes mounted
docker run -d --name temp_restore_container -v tududi_data:/tududi_data_backup_restore -v tududi_uploads:/tududi_uploads_backup_restore alpine
# Copy local files to destination volume within temporary container keeping uid:gid
docker cp -a /tmp/backup/tududi_data/. temp_restore_container:/tududi_data_backup_restore
docker cp -a /tmp/backup/tududi_uploads/. temp_restore_container:/tududi_uploads_backup_restore
# Check contents of destination volumes
docker run --rm -it -v tududi_data:/volume alpine /bin/sh
docker run --rm -it -v tududi_uploads:/volume alpine /bin/sh
# Stop and remove temporary container
docker stop temp_restore_container
docker rm temp_restore_container
# Restart Tududi
docker start tududi
```
