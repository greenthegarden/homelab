# Homelab

## Hardware

## Software

### Architecture

### Deployment

#### TrueNAS

Initial configuration based on [6 Crucial Settings to Enable on TrueNAS SCALE] [ref].

[ref]: https://www.youtube.com/watch?v=dP0wagQVctc
  "6 Crucial Settings to Enable on TrueNAS SCALE"

#### Services

The homleab [Ansible] playbooks to deploy and configure
services used within my Homelab. Repository is structured to
work with [Semaphore UI] to manage the deployments.

[Ansible]: https://docs.ansible.com/ansible/latest/index.html
[Semaphore UI]: https://semaphoreui.com/

### Maintenance

## Guides

### Setting up Semaphore UI

### Managing secrets

```sh
ansible-vault create playbooks/files/config.yaml
```

### Backup Strategy

#### Configuration

All configuration is maintained in this version controlled
repository so is not separately backed up.

The majority of the services are configured at runtime using
either environment variables or labels. Writing configuration,
or .env, files to the file system is kept to a minimum.

#### Container Data

All containers which persist data use [Docker Volumes] [dv]
as data stores, rather than bind mounting directly to the file system.

[dv]: https://docs.docker.com/engine/storage/volumes/

In order to backup the volumes, the service
[docker-volume-backup][dvb] is utilised. The approach
offers a lightweight containerised solution which can
backup locally, to shared volumes, or cloud.

[dvb]: https://github.com/offen/docker-volume-backup
       "docker-volume-backup"

For services which store data outside of a dedicated database,
 the associated data volume is mounted into the
  docker-volume-backup container.

An example of how this is achieved, taken from the
 [deploy-homebox playbook](playbooks/deploy-homebox.yaml), is
  shown below.

```yaml
- name: Deploy a containerised instance of Docker Volume Backup
  ansible.builtin.include_tasks:
    file: tasks/deploy-docker-volume-backup.yaml
  vars:
    docker_volume_backup_volume_to_backup:
        - "{{ homebox_volume_name }}:/backup/homebox-backup:ro"
    docker_volume_backup_backup_label: "{{ homebox_service_name }}"
```

The configuration for docker-volume-backup is managed via the
 [templated .env file](/playbooks/templates/docker-volume-backup/docker-volume-backup.env.j2),
 which is derived from
 [docker-volume-backup Configuration reference] [dvbcr]

[dvbcr]: https://offen.github.io/docker-volume-backup/reference/

A local copy of the data is retained, as well as a copy pushed to
 the TrueNAS server, via ssh. The data is encrypted via GPG.
 Pruning of the backups also is enabled, to ensure only 7 days
 of backups are retained. Backups are initiated `@daily` which
 occurs at midnight.
