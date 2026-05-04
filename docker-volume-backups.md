# Docker Volume Backups

## Creating Backups

Use [`offen/docker-volume-backup`](https://github.com/offen/docker-volume-backup) to m volume backups using [documentation](https://offen.github.io/docker-volume-backup/how-tos/restore-volumes-from-backup.html).

To manually create a backup use the script [create-docker-volume-backups.sh](./create-docker-volume-backups.sh).

The following uses of the script are specific to various hosted services.

* Semaphore

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c semaphore semaphore_config semaphore_data semaphore_tmp
  ```

* Tududi

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c tududi tududi_data tududi_uploads
  ```

* AFFiNE

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c tududi tududi_data tududi_uploads
  ```

Can check the contents of the archived file using, for example

```bash
tar -tvf ${HOME}/archive/backup-beszel-agent-2026-05-02T12-34-57.tar.gz
```

## Restoring form a Backup

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
