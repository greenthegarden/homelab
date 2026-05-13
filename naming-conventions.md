# Naming Conventions

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Services](#services)
- [Networks](#networks)
- [Volumes](#volumes)
- [Implementation Examples](#implementation-examples)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Services

Services are named in lowercase, using `-` to separate multi-word names.

For example

- uptime-kuma
- socket-proxy

Where services combine uses, for example, a database for a service, the names are separated by `_`.

For example

- socket-proxy_homepage
- affine_postgres

Services (containers) can be listed using

```bash
docker ps
```

## Networks

If a service requires a network to connect with dependent services, such as databases, the default name for the network is the service name.

For example

- affine
- socket-proxy_homepage

Networks can be listed using

```bash
docker network ls
```

## Volumes

If a service has a single volumes, default name for the volume is the service name.

Where multiple volumes are required, the format `<service_name>_<use>` is used.

For example

- affine_config
- affine_postgres
- affine_upload

Volumes can be listed using

```bash
docker volume ls
```

## Implementation Examples

Use default settings to achieve most of the naming convention.

```yaml
- name: deploy-paperless-ngx | Set Paperless-ngx facts
  ansible.builtin.set_fact:
    paperless_ngx_image: "{{ paperless_ngx_image | default('ghcr.io/paperless-ngx/paperless-ngx:latest') }}"
    paperless_ngx_service_name: "{{ paperless_ngx_service_name | default('paperless-ngx') }}"
    paperless_ngx_service_port: "{{ paperless_ngx_service_port | default(8000) }}"

- name: deploy-paperless-ngx | Set Paperless-ngx network facts
  ansible.builtin.set_fact:
    paperless_ngx_network_name: "{{ paperless_ngx_network_name | default(paperless_ngx_service_name) }}"

- name: deploy-paperless-ngx | Set Paperless-ngx mount facts
  ansible.builtin.set_fact:
    paperless_ngx_export_dir: "{{ paperless_ngx_export_dir | default('/root/' + paperless_ngx_service_name + '/export') }}"
    paperless_ngx_consume_dir: "{{ paperless_ngx_consume_dir | default('/root/' + paperless_ngx_service_name + '/consume') }}"

- name: deploy-paperless-ngx | Set Paperless-ngx volume facts
  ansible.builtin.set_fact:
    paperless_ngx_volume_data_name: "{{ paperless_ngx_volume_data_name | default(paperless_ngx_service_name + '_data') }}"
    paperless_ngx_volume_media_name: "{{ paperless_ngx_volume_media_name | default(paperless_ngx_service_name + '_media') }}"

- name: deploy-paperless-ngx | Set paperless_ngx aggregated facts
  ansible.builtin.set_fact:
    paperless_ngx_fqdn: "{{ paperless_ngx_service_name }}.{{ ansible_facts['hostname'] }}.{{ homelab.certificate_domain | default('localdomain') }}"

- name: deploy-paperless-ngx | Set Paperless-ngx service facts
  ansible.builtin.set_fact:
    paperless_ngx_networks:
      - { name: "{{ paperless_ngx_network_name }}", internal: true }
      # Reverse Proxy  network is used to expose applications via Traefik
      - { name: "{{ reverse_proxy_network_name | default('reverse-proxy') }}" }
    paperless_ngx_ports:
      # Published ports to expose outside the container
      # host port:container port
      - "{{ paperless_ngx_service_port }}:8000"
    paperless_ngx_mounts:
      # Local paths to mount into the container
      # local path:container path
      - "{{ paperless_ngx_export_dir }}:/usr/src/paperless/export"
      - "{{ paperless_ngx_consume_dir }}:/usr/src/paperless/consume"
    paperless_ngx_volumes:
      # Volumes to mount into the container
      # volume:container path
      - "{{ paperless_ngx_volume_data_name }}:/usr/src/paperless/data"
      - "{{ paperless_ngx_volume_media_name }}:/usr/src/paperless/media"

- name: deploy-paperless-ngx | Log Paperless-ngx configuration
  ansible.builtin.debug:
    msg:
      - "Paperless-ngx image: {{ paperless_ngx_image }}"
      - "Paperless-ngx service name: {{ paperless_ngx_service_name }}"
      - "Paperless-ngx FQDN: {{ paperless_ngx_fqdn }}"
      - "Paperless-ngx networks: {{ paperless_ngx_networks | default(omit) }}"
      - "Paperless-ngx ports: {{ paperless_ngx_ports | default(omit) }}"
      - "Paperless-ngx mounts: {{ paperless_ngx_mounts | default(omit) }}"
      - "Paperless-ngx volumes: {{ paperless_ngx_volumes | default(omit) }}"
```
