#!/usr/bin/env bash

uv tool ansible-playbook --vault-password-file vault.pass playbooks/install-collections.yaml
