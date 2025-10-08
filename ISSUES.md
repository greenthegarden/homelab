# Information to help with issues

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Testing networks](#testing-networks)
- [Postrgres](#postrgres)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Testing networks

Install tools

```sh
# Update apt cache and install
# ping, netcat (nc) and nmap
apt update && apt install -y iputils-ping netcat-traditional nmap
```

Use nmap to scan for open ports on the local host

```sh
nmap host.localdomain
```

Use netcat to check which ports are open using

```sh
nc -zv host.localdomain 1000-10000
```

## Postrgres

Use the `psql` command-line tool running in a Postgres container.

To connect to a PostgreSQL database running in a container, run the following command, with relevant user and database values:

```sh
docker exec -it myPostgresContainer psql -U myUser
```

To list all tables use

```sh
docker exec myPostgresContainer psql -U myUser --list
```

A good source of information is offered in a [DataCamp Tutorial](https://www.datacamp.com/tutorial/postgresql-docker).
