#!/usr/bin/env bash

ansible-galaxy collection install community.docker

ansible-playbook --inventory-file inventory-homelab_lxc.yaml --vault-password-file vault.pass playbooks/deploy-semaphore.yaml
