# SSH Keys

[SSH keys](https://www.ssh.com/academy/ssh/keygen) are generated for the following uses:

* Github (id_ed25519_github): to clone source code to controller
* Semaphore (id_ed25519_semaphore): added to Semaphore container and distributed to all nodes to enable Ansible
* Termix (id_ed25519_termix): add to Termix container and distributed to all nodes to allow remote access via web interface

## Creating Keys

Use the following

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_<name>
```

## Copying Keys to hosts

In order to copy key to hosts ensure ssh access is enabled. If using root, add the line `PermitRootLogin yes` to the file `/etc/ssh/sshd_config` and restart ssh, using `systemctl restart ssh`.

```bash
ssh-copy-id -i ~/.ssh/id_ed25519_<name> user@host
```

After copy the ssh key ensure to disable login, by removing the line `` from the file `/etc/ssh/sshd_config` and restarting ssh, using `systemctl restart ssh`.

Test the key using

```bash
ssh -i ~/.ssh/id_ed25519_<name> user@host
```
