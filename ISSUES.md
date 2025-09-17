# Information to help with issues

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Testing networks](#testing-networks)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Testing networks

Install tools

```sh
# Update apt cache
apt update
# Install ping
apt install iputils-ping -y
# Install nc
apt install netcat-traditional -y
# Install nmap
apt install nmap -y
```

Use nmap to scan for open ports on the local host

```sh
nmap host.localdomain
```

Use netcat to check which ports are open using

```sh
nc -zv host.localdomain 1000-10000
```
