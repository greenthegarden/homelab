# Docker Volume Backups

## Creating Backups

Use [`offen/docker-volume-backup`](https://github.com/offen/docker-volume-backup) to m volume backups using [documentation](https://offen.github.io/docker-volume-backup/how-tos/restore-volumes-from-backup.html).

To manually create a backup use the script [create-docker-volume-backups.sh](./create-docker-volume-backups.sh).

The following uses of the script are specific to various hosted services.

* AFFiNE

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c affine affine_config affine_upload affine_redis affine_postgres
  ```

* Grocy

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c grocy grocy
  ```

* Homebox

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c homebox homebox
  ```

* Semaphore

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c semaphore semaphore_config semaphore_data semaphore_tmp
  ```

* Tududi

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c tududi tududi_data tududi_uploads
  ```

* Vaultwarden

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c vaultwarden vaultwarden
  ```

* Wallos

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c wallos wallos-data wallos-logos
  ```

Can check the contents of the archived file using, for example

```bash
tar -tvf ${HOME}/archive/backup-beszel-agent-2026-05-02T12-34-57.tar.gz
```

## Restoring form a Backup

To [restore from a backup](https://offen.github.io/docker-volume-backup/how-tos/restore-volumes-from-backup.html)

Copy the backup from remote host using

```bash
scp user@host:${HOME}/local-backups/<service>/*.tar.gz .
```

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

### Service specific

#### AFFiNE

```bash
# Stop existing container which will use volume
docker stop affine
docker stop affine_migration
docker stop affine_redis
docker stop affine_postgres
# Extract backups to /tmp
tar -C /tmp -xvf backup-affine-config-2026-05-04T12-55-15.tar.gz
tar -C /tmp -xvf backup-affine-postgres-2026-05-04T12-55-18.tar.gz
tar -C /tmp -xvf backup-affine-redis-2026-05-04T12-55-17.tar.gz
tar -C /tmp -xvf backup-affine-upload-2026-05-04T12-55-15.tar.gz
# Ensure all files have correct uid:gid
chown -R root:root /tmp/backup
# Create temporary container with destination volumes mounted
docker run -d --name temp_restore_container \
  -v affine_config:/affine_config_backup_restore \
  -v affine_upload:/affine_upload_backup_restore \
  -v affine_postgres:/affine_postgres_backup_restore \
  -v affine_redis:/affine_redis_backup_restore \
  alpine
# Copy local files to destination volume within temporary container keeping uid:gid
docker cp -a /tmp/backup/affine_config/. temp_restore_container:/affine_config_backup_restore
docker cp -a /tmp/backup/affine_upload/. temp_restore_container:/affine_upload_backup_restore
docker cp -a /tmp/backup/affine_postgres/. temp_restore_container:/affine_postgres_backup_restore
docker cp -a /tmp/backup/affine_redis/. temp_restore_container:/affine_redis_backup_restore
# Check contents of destination volumes
docker run --rm -it -v affine_config:/volume alpine /bin/sh
docker run --rm -it -v affine_upload:/volume alpine /bin/sh
docker run --rm -it -v affine_postgres:/volume alpine /bin/sh
docker run --rm -it -v affine_redis:/volume alpine /bin/sh
# Stop and remove temporary container
docker stop temp_restore_container
docker rm temp_restore_container
# Restart Tududi
docker start affine_redis
docker start affine_postgres
docker start affine_migration
docker start affine
```

#### Homebox

```bash
# Stop existing container which will use volume
docker stop homebox
# Extract homebox backup to /tmp
tar -C /tmp -xvf backup-homebox-2026-05-02T12-50-44.tar.gz
# Ensure all files have correct uid:gid
chown -R root:root /tmp/backup
# Create temporary container with destination volumes mounted
docker run -d --name temp_restore_container -v homebox:/homebox_backup_restore alpine
# Copy local files to destination volume within temporary container keeping uid:gid
docker cp -a /tmp/backup/homebox/. temp_restore_container:/homebox_backup_restore
# Check contents of destination volumes
docker run --rm -it -v homebox:/volume alpine /bin/sh
# Stop and remove temporary container
docker stop temp_restore_container
docker rm temp_restore_container
# Restart container
docker start homebox
```

#### Tududi

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

#### Wallos

```bash
# Stop existing container which will use volume
docker stop wallos
# Extract homebox backup to /tmp
tar -C /tmp -xf backup-wallos-data-2026-05-05T10-10-44.tar.gz
tar -C /tmp -xf backup-wallos-logos-2026-05-05T10-10-59.tar.gz
# Ensure all files have correct uid:gid
chown -R root:root /tmp/backup
# Create temporary container with destination volumes mounted
docker run -d --name temp_restore_container -v wallos_data:/wallos_data_backup_restore -v wallos_logos:/wallos_logos_backup_restore alpine
# Copy local files to destination volume within temporary container keeping uid:gid
docker cp -a /tmp/backup/wallos-data/. temp_restore_container:/wallos_data_backup_restore
docker cp -a /tmp/backup/wallos-logos/. temp_restore_container:/wallos_logos_backup_restore
# Check contents of destination volumes
docker run --rm -it -v wallos_data:/volume alpine /bin/sh
docker run --rm -it -v wallos_logos:/volume alpine /bin/sh
# Stop and remove temporary container
docker stop temp_restore_container
docker rm temp_restore_container
# Restart container
docker start wallos
```
