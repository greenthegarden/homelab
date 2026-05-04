# Naming Convensions

## Services

Services are named in lowercase, using `-` to separate multi-word names.

For example

* uptime-kuma
* socket-proxy

Where services combine uses, for example, a database for a service, the names are separated by `_`.

For example

* socket-proxy_homepage
* affine_postgres

Services (containers) can be listed using

```bash
docker ps
```

## Networks

If a service requires a network to connect with dependent services, such as databases, the default name for the network is the service name.

For example

* affine
* socket-proxy_homepage

Networks can be listed using

```bash
docker network ls
```

## Volumes

If a service has a single volumes, default name for the volume is the service name.

Where multiple volumes are required, the format `<service_name>_<use>` is used.

For example

* affine_config
* affine_postgres
* affine_upload

Volumes can be listed using

```bash
docker volume ls
```
