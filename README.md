# Homelab

## Hardware

## Software

### Architecture

### Deployment

#### TrueNAS

Initial configuration based on [6 Crucial Settings to Enable on TrueNAS SCALE](https://www.youtube.com/watch?v=dP0wagQVctc)

#### Services

The homleab
[Ansible](https://docs.ansible.com/ansible/latest/index.html) playbooks to deploy
and configure services used within my Homelab. Repository is structured to work with
[Semaphore UI](https://semaphoreui.com/) to manage the deployments.

### Maintenance

## Guides

### Setting up Semaphore UI

### Managing secrets

```yaml
ansible-vault create playbooks/files/config.yaml
```

### Backup Strategy

All configuration is maintained in this version controlled repository so
