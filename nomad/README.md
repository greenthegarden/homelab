# Service Orchestration using Nomad

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Background](#background)
- [Configuration](#configuration)
  - [Consul](#consul)
  - [Nomad](#nomad)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Background

Hashicorp Nomad is used to orchestrate services on the RPi.

Information used to install and configure Nomad is based on [Medium post][medium-nomad].

[medium-nomad]: https://medium.com/swlh/running-hashicorp-nomad-consul-pihole-and-gitea-on-raspberry-pi-3-b-f3f0d66c907

## Configuration

### Consul

The Consul server is configure with the following defined at `/data/consul/consul.d/server.json`.

```json
{
  "server": true,
  "datacenter": "dc1",
  "data_dir": "/data/consul/data",
  "ui": true,
  "bind_addr": "127.0.0.1",
  "client_addr": "192.168.1.2",
  "bootstrap_expect": 1,
  "ports": {
    "grpc": 8502
  },
  "connect": {
    "enabled": true
  },
  "encrypt": "encryption-key-to-generate"
}
```

The encryption key was generated using

```bash
consul keygen
```

The Consul service is run using the following systemctl definition.

```bash
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/data/consul/consul.d/server.json

[Service]
Type=simple
User=consul
Group=consul
ExecStart=/usr/bin/consul agent -config-dir=/data/consul/consul.d/
ExecReload=/usr/bin/consul reload
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

### Nomad

The Nomad server is configured with the following defined at `/data/nomad/nomad.d/server.hcl`.

```hcl
server {
  enabled = true
  bootstrap_expect = 1
  # Encrypt gossip communication
#  encrypt = ymmR+IzfYBw/ZbX6svpYELn0NhPckdUxlDpUqzohqi4=
}

data_dir  = "/data/nomad/data"
datacenter = "dc1"

bind_addr = "0.0.0.0"

ports {
  http = 4646
  rpc  = 4647
  serf = 4648
}

consul {
  address = "127.0.0.1:8500"
}

acl {
  enabled    = false
  token_ttl  = "30s"
  policy_ttl = "60s"
}
```

The Nomad client is configure with the following defined at `/data/nomad/nomad.d/client.hcl`.

```hcl
client {
  enabled = true
  network_interface = "eth0"
  server_join {
    retry_join = [
      "127.0.0.1"
    ]
    retry_max = 3
    retry_interval = "15s"
  }
}
```

Looks like [best practice][hashicorp-disc-nomad] is to run nomad as root,
although the [official documentation suggests otherwise][hashicorp-docs-nomad]. I am running it as root.

[hashicorp-docs-nomad]: https://developer.hashicorp.com/nomad/docs/drivers/docker#client-requirements
[hashicorp-disc-nomad]: https://discuss.hashicorp.com/t/nomad-1-7-x-problems-with-docker-driver/61096/7

The Nomad services are run using the following systemctl definition.

```bash
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

# When using Nomad with Consul it is not necessary to start Consul first. These
# lines start Consul before Nomad as an optimization to avoid Nomad logging
# that Consul is unavailable at startup.
Wants=consul.service
After=consul.service

[Service]
Type=simple
User=root
Group=root
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/bin/nomad agent -config /data/nomad/nomad.d
ExecStop=/bin/kill $MAINPID
KillMode=process
KillSignal=SIGINT
LimitNOFILE=65536
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
TasksMax=infinity
OOMScoreAdjust=-1000

[Install]
WantedBy=multi-user.target
```
