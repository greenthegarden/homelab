<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Homelab](#homelab)
  - [Hardware](#hardware)
    - [Network Hardware](#network-hardware)
    - [Compute Server Hardware](#compute-server-hardware)
    - [Storage Server Hardware](#storage-server-hardware)
  - [Software](#software)
    - [Compute Server Software](#compute-server-software)
    - [Storage Server Software](#storage-server-software)
    - [Homelab Services](#homelab-services)
      - [LXC Service Deployment](#lxc-service-deployment)
    - [Maintenance](#maintenance)
  - [Guides](#guides)
    - [Setting up Semaphore UI](#setting-up-semaphore-ui)
    - [Managing secrets](#managing-secrets)
    - [Backup Strategy](#backup-strategy)
      - [Container Configuration](#container-configuration)
      - [Container Data](#container-data)
      - [Off-Site Backup](#off-site-backup)
      - [Nextcloud AOI](#nextcloud-aoi)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Homelab

Welcome to my Homelab definition-in-code! The repository consists largely of Ansible code which is used
to provision and maintain the services which make up the functionality provided by my homelab.

Please feel free to reuse any of the code or provide feedback and suggestions.

## Hardware

Add picture!!

### Network Hardware

A [Ubiquity CLoud Gateway Ultra][network] is used to manage the network aspects of the Homelab.

[network]: https://techspecs.ui.com/unifi/unifi-cloud-gateways/ucg-ultra

### Compute Server Hardware

I selected the [Beelink SEi12 i5-1235U Intel 12 Gen Mini PC][compserv]
as a Homelab compute server. The system uses an i5-1235U processor, which with 10 cores,
provides a good amount of parallel processing in a compact unit.

[compserv]: https://www.bee-link.com/beelink-minipc-intel-i5-12-gen-sei1235u

Server Specifications

|   |   |
|---|---|
| CPU | Intel Core i5-1235U 2P-8E-12H 3.3-4.4GHz / 15-55 W TDP / 10 nm (Intel 7) |
| GPU | Intel Xe / 80 EU / 1200 MHz |
| RAM | 16/32GB DDR4 3200MHz max Crucial / 2x SODIMM |
| Storage | 500GB/1TB 1x M.2 2280 NVMe / 1x SATA 3 2.5″ |
| Network | 1x Gigabit Ethernet (Realtek) |
| Ports | 1x USB 3.1 Type-C (data) / 2x USB 3.0 / 2x USB 2.0 / 2x HDMI 2.1 / Audio Jack / BIOS Reset |

### Storage Server Hardware

For a Storage server I am using a [ZimaBlade 7700 NAS kit][storserv], which uses a quad-core version
of the Zimablade single-board x86 computer. For storage, two Seagate Barracuda Green 2TB SATA hard drives
are used.

[storserv]: https://www.crowdsupply.com/icewhale-technology/zimablade

Server Specifications

|   |   |
|---|---|
| CPU | Intel® Celeron with 2.4 GHz Turbo Speed |
| | Intel® AES New Instructions |
| | Intel® Virtualization Technology (VT-x) |
| | Intel® Virtualization Technology for Directed I/O (VT-d) |
| Memory | 16 GB DDR3L RAM |
| Storage | Integrated 32 GB eMMC |
| Network | 1 x 10/100/1000 Mbps Gigabit Ethernet |
| PCIe | 1 x PCIe 2.0, four lanes |
| SATA | 2 x SATA 3.0 |
| Power | 45 W USB Type-C power adapter |
| Thermal | 6 W TDP with passive cooling |

## Software

### Compute Server Software

The compute server is running [Proxmox Virtual Environment 8 hypervisor][compsoft]
as the OS. This allows both virtual machines and Linux Containers (LXC) to be used to host the
services and applications within the Homelab.

[compsoft]: https://www.proxmox.com/en/products/proxmox-virtual-environment/overview

Proxmox 8 was installed on top of Debian 12 as I was unable to boot directly into the Proxmox installer.

### Storage Server Software

The storage service is running [TrueNAS Scale Community Edition][storsoft] as the storage solution.

[storsoft]: https://www.truenas.com/truenas-community-edition/

TrueNAS Scale ElectricEel-24.10.2 was installed directly on to the Zomaboard.

Initial configuration was based on [6 Crucial Settings to Enable on TrueNAS SCALE] [ref].

[ref]: https://www.youtube.com/watch?v=dP0wagQVctc
  "6 Crucial Settings to Enable on TrueNAS SCALE"

### Homelab Services

As mentioned the current iteration of the Homelab hosts the following applications:

- [Nextcloud][nextcloud] - Open source content collaboration platform.
- [Home Assistant][homeassistant] - Open source home automation that puts local control and privacy first.
- [Authentik][authentik] - Identity manager.
- [EMQX][emqx] - MQTT platform.
- [Firefly III][fireflyiii] - A free and open source personal finance manager.
- [Frigate][frigate] - An open source NVR.
- [Grafana][grafana] - An open source tool to create dashboards.
- [Grocy][grocy] - An open source web-based self-hosted groceries & household management solution.
- [Homebox][homebox] - An open source inventory and organization system.
- [Homepage][homepage] - A modern, fully static, fast, secure fully proxied, highly customizable application dashboard.
- [Hortusfox][hortusfox] - A free and open-sourced self-hosted plant manager system.
- [InfluxDB][influxdb] - A time-series database.
- [Portainer][portainer] - A universal container management platform.
- [Semaphore][semaphore] - User friendly web interface for executing Ansible playbooks, Terraform, OpenTofu code and Bash scripts.
- [Uptime Kuma][uptimekuma] - An easy-to-use self-hosted monitoring tool.
- [Vaultwarden][vaultwarden] - An alternative server implementation of the Bitwarden Client API
- [WUD (What's up Docker)][wud] - A tool to keep Docker containers up-to-date

[nextcloud]: https://nextcloud.com/
[homeassistant]: https://www.home-assistant.io/
[authentik]: https://goauthentik.io/
[emqx]: https://www.emqx.com/en
[fireflyiii]: https://www.firefly-iii.org/
[frigate]: https://frigate.video/
[grafana]: https://grafana.com/
[grocy]: https://grocy.info/
[homebox]: https://github.com/sysadminsmedia/homebox
[homepage]: https://gethomepage.dev/
[hortusfox]: https://www.hortusfox.com/
[influxdb]: https://www.influxdata.com/
[portainer]: https://www.portainer.io/
[semaphore]: https://semaphoreui.com/
[uptimekuma]: https://github.com/louislam/uptime-kuma
[vaultwarden]: https://github.com/dani-garcia/vaultwarden
[wud]: https://getwud.github.io/wud/#/

Underpinning the applications are a number of other services

- [Docker Socket Proxy][dockersocketproxy] - A security-enhanced proxy for the Docker Socket.
- [Portainer Agent][portaineragent] -  Provide a Portainer Server instance with access to node resources.
- [Node Exporter][nodeexporter]- Prometheus exporter for hardware and OS metrics.
- [Prometheus][prometheus] - An open-source systems monitoring and alerting toolkit.
- [Traefik][traefik] - An open source application proxy.
- [Docker Volume Backup][dockervolumebackup] - Companion container to backup Docker volumes.

[dockersocketproxy]: https://github.com/Tecnativa/docker-socket-proxy
[portaineragent]: https://docs.portainer.io/admin/environments/add/docker/agent
[nodeexporter]: https://github.com/prometheus/node_exporter
[prometheus]: https://prometheus.io/
[traefik]: https://doc.traefik.io/traefik/
[dockervolumebackup]: https://github.com/offen/docker-volume-backup

#### LXC Service Deployment

The Homelab [Ansible] playbooks to deploy and configure
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

#### Container Configuration

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

A label is added to the associated container, to ensure the
container is stopped before the data volume is backed up. An
example of this, taken from
[deploy-homebox task](playbooks/tasks/deploy-homebox.yaml), is shown below.

```yaml
- name: Create Homebox container labels
  ansible.builtin.set_fact:
    homebox_container_labels: "{{ homebox_container_labels | default({}) | combine({item.key: item.value}) }}"
  with_items:
    ...
    # Docker Volume Backup labels
    - { "key": "docker-volume-backup.stop-during-backup", "value": "true" }
    ...
```

```yaml
    - name: Deploy Homebox
      community.docker.docker_container:
        name: "{{ homebox_service_name }}"
        image: "{{ homebox_image }}"
        detach: true
        env:
          HBOX_LOG_LEVEL: "info"
          HBOX_LOG_FORMAT: "text"
          HBOX_WEB_MAX_UPLOAD_SIZE: "10"
          TZ: "{{ homelab.timezone | default(omit) }}"
        labels: "{{ (homebox_container_labels | default({})) | default(omit) }}"
        networks_cli_compatible: true
        networks: "{{ homebox_networks }}"
        restart: true
        restart_policy: unless-stopped
        state: started
        volumes: "{{ homebox_volumes }}"
      register: homebox_container_state
```

For services which store data in a separate database
container, the database contents are dumped to a file, which
is then backed up.

For MariaDB databases, the backup is achieved using
`mariadb-dump`, an example of which, taken from
[deploy-hortusfox task](/playbooks/tasks/deploy-hortusfox.yaml),
is shown below.

```yaml
- name: Create Hortusfox DB container labels
  ansible.builtin.set_fact:
    hortusfox_db_container_labels: "{{ hortusfox_db_container_labels | default({}) | combine({item.key: item.value}) }}"
  with_items:
    # Docker Volume Backup labels
    - {
      "key": "docker-volume-backup.archive-pre",
      "value": "/bin/sh -c 'mariadb-dump --single-transaction --user={{ hortusfox.db_user }} -p{{ hortusfox.db_password }} --all-databases > /tmp/dumps/dump.sql'"
    }
```

In addition, a dedicated volume is created to store the backup file, an example of which, taken from
[deploy-hortusfox task](/playbooks/tasks/deploy-hortusfox.yaml),
is shown below.

```yaml
- name: Create Hortusfox backup volume  # noqa: syntax-check[unknown-module]
  community.docker.docker_volume:
    name: "{{ hortusfox_db_backup_volume_name }}"
    state: present
```

Within the associated deployment of the database service, the
 volume is mounted into the container, an example of which,
 taken from [hortusfox/docker-compose.yml](/playbooks/templates/hortusfox/docker-compose.yml.j2),
 is shown below.

```yaml
  db:
    container_name: hortusfox_db
    image: mariadb:lts
    environment:
      MYSQL_ROOT_PASSWORD: {{ hortusfox.db_root_password | default('dummy') }}
      MYSQL_DATABASE: {{ hortusfox.db_database | default('hortusfox') }}
      MYSQL_USER: {{ hortusfox.db_user | default('hortusfox') }}
      MYSQL_PASSWORD: {{ hortusfox.db_password | default('dummy') }}
    hostname: db
    labels: {{ (hortusfox_db_container_labels | default({})) | default(omit) }}
    networks:
      - hortusfox
    restart: always
    volumes:
      - db_data:/var/lib/mysql
      - {{ hortusfox_db_backup_volume_name | default('hortusfox_db_backup') }}:/tmp/dumps
```

In the case where docker-compose is used to deploy the containers, the volume needs to assigned as `external`, an example of which,
 taken from [hortusfox/docker-compose.yml](/playbooks/templates/hortusfox/docker-compose.yml.j2),
 is shown below.

```yaml
volumes:

  db_data:
  {{ hortusfox_db_backup_volume_name | default('hortusfox_db_backup') }}:
    external: true
  app_images:
  app_logs:
  app_backup:
  app_themes:
  app_migrate:
```

As volume must also be mounted to the docker-volume-backup
container, an example of which, taken from
[deploy-hortusfox.yaml playbook](/playbooks/deploy-hortusfox.yaml), is shown below.

```yaml
- name: Deploy a containerised instance of Docker Volume Backup
  ansible.builtin.include_tasks:
    file: tasks/deploy-docker-volume-backup.yaml
  vars:
    docker_volume_backup_volume_to_backup:
      - "{{ hortusfox_db_backup_volume_name }}:/backup/hortusfox_db-backup:ro"
    docker_volume_backup_backup_label: "{{ hortusfox_service_name }}-db"
```

NOTE: I could not get the database backups to work using
docker-socket-proxy and had to bind to the docker socket
directly.

#### Off-Site Backup

For off-site backup, a `Cloud Sync Task` is configured
within the TrueNAS server to push the backup files created by
 docker-volume-backup to a cloud storage provider. The task
 is scheduled to be run daily at 1am.

#### Nextcloud AOI

Nextcloud AOI (All in One) uses BorgBackup to manage backups. An issue with the way
the back up location is configured is that it cannot easily be changed once it is
initially set.

A way to manage this is described in the [Github project page][nxtcldaio] using
the following to be able to have the `Reset backup location` button show in the
AIO Interface.

[nxtcldaio]: https://github.com/nextcloud/all-in-one/discussions/596

```bash
root@nextcloud:~# docker exec nextcloud-aio-mastercontainer rm /mnt/docker-aio-config/data/borg.config
```

Refer to the [TrueNAS documentation][tndnfs] for creating NFS Shares. Ensure `Maproot User`
and `Maproot Group` are both set to `root` within the Advanced Options.

[tndnfs]: https://www.truenas.com/docs/scale/24.10/scaletutorials/shares/addingnfsshares

To use an external location for the backups, a mount point to the host operating system
needs to be created.

```bash
root@nextcloud:~# mkdir -p /mnt/truenas/backup
```

To test the mount point use `mount -t nfs {IPaddressOfTrueNASsystem}:{path/to/nfsShare} {localMountPoint}`.

```bash
root@nextcloud:~# mount -t nfs truenas:/mnt/homelab-backup/nextcloud-aio-backup /mnt/truenas/backup
```

Set the mount within `/etc/fstab` to ensure it is persistent, by adding the following

```bash
truenas:/mnt/homelab-backup/nextcloud-aio-backup /mnt/truenas/backup nfs defaults 0 0
```

Then apply it using

```bash
root@nextcloud:~# mount /mnt/truenas/backup
```

Use a Remote borg repo - could not get this to work

```bash
ssh://user@host:port/path/to/repo
ssh://nextcloud@truenas:2222/mnt/homelab-backup/nextcloud-aio-backup
```
