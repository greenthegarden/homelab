# Homelab

## Hardware

## Software

### Architecture

### Deployment

#### TrueNAS

Initial configuration based on [TrueNAS Scale Settings][].

[TrueNAS Scale Settings]: https://www.youtube.com/watch?v=dP0wagQVctc
(6 Crucial Settings to Enable on TrueNAS SCALE)

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
repository so it not separately backed up

#### Container Data

All containers
