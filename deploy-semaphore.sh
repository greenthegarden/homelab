#!/usr/bin/env bash

ansible-playbook --inventory-file hosts.yaml --vault-password-file vault.pass playbooks/deploy-semaphore.yaml
