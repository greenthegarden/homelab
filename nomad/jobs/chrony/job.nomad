job "chrony-job" {
  region = "global"
  datacenters = [
    "dc1",
  ]
  type = "service"

  group "chrony-group" {
    count = 1
    restart {
      attempts = 5
      delay    = "30s"
    }
    network {
      port "ntp" {
        static = 123
      }
    }
    task "chrony" {
      driver = "docker"
      config {
        image = "dockurr/chrony:latest"
        ports = ["ntp"]
      }
      env = {
        "NTP_SERVERS" = "0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org,3.pool.ntp.org"
      }
      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
