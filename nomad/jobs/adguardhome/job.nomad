job "adguardhome" {
  region = "global"
  datacenters = [
      "lan0",
    ]
  type = "service"
  group "svc" {
    count = 1
    restart {
      attempts = 5
      delay    = "15s"
    }
    task "app" {
      driver = "docker"
      config {
        image = "adguard/adguardhome:latest"
        mounts = [
          {
            type     = "bind"
            target   = "/opt/adguardhome/work"
            source   = "/data/nomad/data/adguardhome/work"
            readonly = false
          },
          {
            type     = "bind"
            target   = "/opt/adguardhome/conf"
            source   = "/mnt/storage/nomad/data/adguardhome/conf"
            readonly = false
          },
        ]
        port_map {
          dns  = 53
          http = 80
          dns_over_http = 3000
        }
        dns_servers = [
          "127.0.0.1",
          "192.168.1.1",
        ]
      }
      env = {
        "TZ" = "Australia/Adelaide"
      }
      resources {
        cpu    = 100
        memory = 128
        network {
          port "dns" {
            static = 53
          }
          port "http" {}
          port "dns_over_http" {}
        }
      }
    }
    service {
      name = "adguardhome-admin-panel"
      port = "http"
    }
  }
}
