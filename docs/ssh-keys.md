# SSH Keys

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Creating Keys Pairs](#creating-keys-pairs)
- [Copying Public Keys to Hosts](#copying-public-keys-to-hosts)
- [Specific Keys](#specific-keys)
  - [Github](#github)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[SSH keys](https://www.ssh.com/academy/ssh/keygen) are generated for the following uses:

- Github (id_ed25519_github): to clone source code to controller
- Semaphore (id_ed25519_semaphore): added to Semaphore container and distributed to all nodes to enable Ansible
- Termix (id_ed25519_termix): add to Termix container and distributed to all nodes to allow remote access via web interface

## Creating Keys Pairs

Use the following

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_<name> -C <comment>
```

## Copying Public Keys to Hosts

In order to copy the public key to hosts ensure ssh access is enabled on the host. If using root,

- add the line `PermitRootLogin yes` to the file `/etc/ssh/sshd_config` and,
- restart ssh, using `systemctl restart ssh`.

```bash
ssh-copy-id -i ~/.ssh/id_ed25519_<name> user@host
```

After copy the ssh key ensure to disable root login, by

- removing the line `PermitRootLogin yes` from the file `/etc/ssh/sshd_config` and,
- restarting ssh, using `systemctl restart ssh`.

Test the key using

```bash
ssh -i ~/.ssh/id_ed25519_<name> user@host
```

## Specific Keys

### Github

To create a key for [Github](https://github.com), use

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -c "Github push"
```

Add the following to the file `~/.ssh/config`

```bash
Host github.com
  IdentityFile ~/.ssh/id_ed25519_github
```
