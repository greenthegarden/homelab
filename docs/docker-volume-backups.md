# Docker Volume Backups

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Creating Backups](#creating-backups)
- [Restoring form a Backup](#restoring-form-a-backup)
  - [Service specific](#service-specific)
    - [AFFiNE](#affine)
    - [Firefly III](#firefly-iii)
    - [Grist](#grist)
    - [Grocy](#grocy)
    - [Homebox](#homebox)
    - [Paperless-ngx](#paperless-ngx)
    - [Tududi](#tududi)
    - [Vaultwarden](#vaultwarden)
    - [Wallos](#wallos)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Creating Backups

Use [`offen/docker-volume-backup`](https://github.com/offen/docker-volume-backup) to m volume backups using [documentation](https://offen.github.io/docker-volume-backup/how-tos/restore-volumes-from-backup.html).

To manually create a backup use the script [create-docker-volume-backups.sh](./create-docker-volume-backups.sh).

The following uses of the script are specific to various hosted services.

- AFFiNE

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c affine affine_config affine_upload affine_redis affine_postgres
  ```

- Firefly III

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c firefly_iii fireflyiii_firefly_iii_db fireflyiii_firefly_iii_upload
  ```

- Grist

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c grist grist
  ```

- Grocy

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c grocy grocy
  ```

- Homebox

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c homebox homebox
  ```

- Homebox

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c paperless-ngx paperless-ngx-data paperless-ngx-media paperless-ngx-redis
  ```

- Semaphore

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c semaphore semaphore_config semaphore_data semaphore_tmp
  ```

- Tududi

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c tududi tududi_data tududi_uploads
  ```

- Vaultwarden

  ```bash
  ./create-docker-volume-backups.sh -f ${HOME}/local-backups -c vaultwarden vaultwarden
  ```

- Wallos

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

- Stop the container(s) that are using the volume
- Untar the backup you want to restore

  ```bash
  tar -C /tmp -xvf  backup.tar.gz
  ```

- Using a temporary once-off container, mount the volume (the example assumes it’s named data) and copy over the backup.
  Make sure you copy the correct path level (this depends on how you mount your volume into the backup container),
  you might need to strip some leading elements

  ```bash
  docker run -d --name temp_restore_container -v data:/backup_restore alpine
  docker cp /tmp/backup/data-backup temp_restore_container:/backup_restore
  docker stop temp_restore_container
  docker rm temp_restore_container
  ```

- Restart the container(s) that are using the volume

### Service specific

#### AFFiNE

```bash
# Stop and remove containers using volume(s), and then remove volume(s)
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
# Redeploy service
```

#### Firefly III

```bash
# Stop and remove containers using volume(s), and then remove volume(s)
# Extract firefly iii backup to /tmp
tar -C /tmp -xvf backup-fireflyiii_firefly_iii_db-2026-05-06T11-58-26.tar.gz
tar -C /tmp -xvf backup-fireflyiii_firefly_iii_upload-2026-05-06T11-58-33.tar.gz
# Ensure all files have correct uid:gid
chown -R root:root /tmp/backup
# Create temporary container with destination volumes mounted
docker run -d --name temp_restore_container -v fireflyiii_firefly_iii_db:/firefly_db_restore -v fireflyiii_firefly_iii_upload:/firefly_upload_restore alpine
# Copy local files to destination volume within temporary container keeping uid:gid
docker cp -a /tmp/backup/fireflyiii_firefly_iii_db/. temp_restore_container:/firefly_db_restore
docker cp -a /tmp/backup/fireflyiii_firefly_iii_upload/. temp_restore_container:/firefly_upload_restore
# Check contents of destination volumes
docker run --rm -it -v fireflyiii_firefly_iii_db:/volume alpine /bin/sh
docker run --rm -it -v fireflyiii_firefly_iii_upload:/volume alpine /bin/sh
# Stop and remove temporary container
docker stop temp_restore_container
docker rm temp_restore_container
# Redeploy service
```

#### Grist

```bash
# Stop and remove containers using volume(s), and then remove volume(s)
# Extract grocy backup to /tmp
tar -C /tmp -xvf backup-grist-2026-05-06T10-18-15.tar.gz
# Ensure all files have correct uid:gid
chown -R root:root /tmp/backup
# Create temporary container with destination volumes mounted
docker run -d --name temp_restore_container -v grist:/grist_backup_restore alpine
# Copy local files to destination volume within temporary container keeping uid:gid
docker cp -a /tmp/backup/grist/. temp_restore_container:/grist_backup_restore
# Check contents of destination volumes
docker run --rm -it -v grist:/volume alpine /bin/sh
# Stop and remove temporary container
docker stop temp_restore_container
docker rm temp_restore_container
# Redeploy service
```

#### Grocy

```bash
# Stop and remove containers using volume(s), and then remove volume(s)
# Extract grocy backup to /tmp
tar -C /tmp -xvf backup-grocy-2026-05-05T21-05-32.tar.gz
# Ensure all files have correct uid:gid
chown -R root:root /tmp/backup
# Create temporary container with destination volumes mounted
docker run -d --name temp_restore_container -v grocy:/grocy_backup_restore alpine
# Copy local files to destination volume within temporary container keeping uid:gid
docker cp -a /tmp/backup/grocy/. temp_restore_container:/grocy_backup_restore
# Check contents of destination volumes
docker run --rm -it -v grocy:/volume alpine /bin/sh
# Stop and remove temporary container
docker stop temp_restore_container
docker rm temp_restore_container
# Redeploy service
```

#### Homebox

```bash
# Stop and remove containers using volume(s), and then remove volume(s)
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
# Redeploy service
```

#### Paperless-ngx

```bash
# Stop and remove containers using volume(s), and then remove volume(s)
# Extract paperless-ngx backup to /tmp
tar -C /tmp -xvf backup-paperless-ngx-data-2026-05-05T21-38-04.tar.gz
tar -C /tmp -xvf backup-paperless-ngx-media-2026-05-05T21-38-06.tar.gz
tar -C /tmp -xvf backup-paperless-ngx-redis-2026-05-05T21-38-27.tar.gz
# Ensure all files have correct uid:gid
chown -R root:root /tmp/backup
# Create temporary container with destination volumes mounted
docker run -d --name temp_restore_container \
  -v paperless-ngx_data:/paperless-ngx_data_backup_restore \
  -v paperless-ngx_media:/paperless-ngx_media_backup_restore \
  -v paperless-ngx_redis:/paperless-ngx_redis_backup_restore \
  alpine
# Copy local files to destination volume within temporary container keeping uid:gid
docker cp -a /tmp/backup/paperless-ngx-data/. temp_restore_container:/paperless-ngx_data_backup_restore
docker cp -a /tmp/backup/paperless-ngx-media/. temp_restore_container:/paperless-ngx_media_backup_restore
docker cp -a /tmp/backup/paperless-ngx-redis/. temp_restore_container:/paperless-ngx_redis_backup_restore
# Check contents of destination volumes
docker run --rm -it -v paperless-ngx_data:/volume alpine /bin/sh
docker run --rm -it -v paperless-ngx_media:/volume alpine /bin/sh
docker run --rm -it -v paperless-ngx_redis:/volume alpine /bin/sh
# Stop and remove temporary container
docker stop temp_restore_container
docker rm temp_restore_container
# Redeploy service
```

#### Tududi

```bash
# Stop and remove containers using volume(s), and then remove volume(s)
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
# Redeploy service
```

#### Vaultwarden

```bash
# Stop and remove containers using volume(s), and then remove volume(s)
# Extract vaultwarden backup to /tmp
tar -C /tmp -xvf backup-vaultwarden-2026-05-05T21-20-37.tar.gz
# Ensure all files have correct uid:gid
chown -R root:root /tmp/backup
# Create temporary container with destination volumes mounted
docker run -d --name temp_restore_container -v vaultwarden:/vaultwarden_backup_restore alpine
# Copy local files to destination volume within temporary container keeping uid:gid
docker cp -a /tmp/backup/vaultwarden/. temp_restore_container:/vaultwarden_backup_restore
# Check contents of destination volumes
docker run --rm -it -v vaultwarden:/volume alpine /bin/sh
# Stop and remove temporary container
docker stop temp_restore_container
docker rm temp_restore_container
# Redeploy service
```

#### Wallos

```bash
# Stop and remove containers using volume(s), and then remove volume(s)
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
# Redeploy service
```
