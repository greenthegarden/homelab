#!/usr/bin/env bash

ansible-playbook --inventory-file inventory-homelab_lxc.yaml --vault-password-file vault.pass playbooks/deploy-semaphore.yaml
