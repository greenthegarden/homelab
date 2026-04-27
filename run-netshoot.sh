#!/usr/bin/env bash
#
#
# Source: https://www.howtogeek.com/these-docker-containers-turned-my-homelab-into-the-ultimate-network-diagnostics-tool/
#
# Netshoot
#
# All the tools you need for network diagnostics in one container
#
# When a service goes down or misbehaves, the next step is to
# figure out what's wrong.
#
# You might have noticed that a typical Docker compose file has
# a "network" flag. It defines a virtual network for that container.
# Docker containers usually don't use the host network directly.
# So if you want to figure out what's wrong with that virtual
# network, you can't do so directly from the host. That's what
# Netshoot is for.
#
# You can list virtual Docker networks with this command.
#
# docker network ls
#
# You can run Netshoot as a temporary Docker container that
# lets you interact with any of the Docker networks on your list.
# Substitute bridge with your target network. The '--rm -it' flags
# tell Docker to remove this container when you exit it and give
# you an interactive shell.
#
# docker run --rm -it --network bridge nicolaka/netshoot
#
# To target a particular container, run this command.
#
# docker run --rm -it --network container: nicolaka/netshoot
#

docker run --rm -it --network bridge nicolaka/netshoot

# Netstat
#
# Use `netstat -plnt` to list the TCP ports that are being
# listened on.
