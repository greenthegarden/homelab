# Nexcloud Configuration

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Requirement](#requirement)
- [Create NFS share](#create-nfs-share)
- [Mounting NFS Share to an Unprivileged LXC](#mounting-nfs-share-to-an-unprivileged-lxc)
- [Illustrating Permissions](#illustrating-permissions)
  - [What the LXC sees](#what-the-lxc-sees)
  - [What the NFS server and the PVE host sees](#what-the-nfs-server-and-the-pve-host-sees)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Requirement

Run Nextcloud via [Nextcloud AIO][nextcloud-aio] but store data on nfs share hosted via TrueNAS.

[nextcloud-aio]: https://github.com/nextcloud/all-in-one

## Create NFS share

Click on the Shares tab
Select your share (e.g. downloads)
Scroll to the NFS Security Settings
Set Export to Yes
Set Security to Private
Add a rule that allows your node read/write access
node_ip(sec=sys,rw)
Ex: 192.168.1.254(sec=sys,rw)

[truenas-nfs]

## Mounting NFS Share to an Unprivileged LXC

Following [one][bobcares-nfs], [two][itsembedded], [three][cr0x.net] guides, mount the NFS share directly without using the Proxmox GUI.

- Create a mount point on the Proxmox node for the share:

  ```bash
  # Via Proxmox server shell
  mkdir /mnt/truenas/nextcloud_data
  ```

- Edit `fstab` so that the share mounts automatically when the Proxmox Datacentre is rebooted

  ```bash
  # Via Proxmox server shell
  vi /etc/fstab
  # add the line
  truenas.localdomain:/mnt/nextcloud_data/ /mnt/truenas/nextcloud_data nfs defaults 0 0
  ```

- Reload systemd and mount

  ```bash
  # Via Proxmox server shell
  systemctl daemon-reload
  mount -a
  ```

- Map the mount to the Container

  ```bash
  # Via Proxmox server shell
  nano /etc/pve/lxc/400.conf
  # add the line
  mp0: /mnt/truenas/nextcloud_data,mp=/mnt/nextcloud_data
  ```

- Start the LXC

- Adjust LXC user permissions

  ```bash
  groupadd -g 10000 lxc_shares # group name can be anything but is same as in next step
  usermod -aG lxc_shares root # assumes username is root
  ```

- Reboot LXC
- Verify Permissions
  - Create a file in the mount point: `touch foobar`
  - Attempt to delete the file from another machine

[bobcares-nfs]: https://bobcares.com/blog/guide-to-mounting-nfs-share-to-an-unprivileged-lxc-container/
[itsembedded]: https://www.itsembedded.com/sysadmin/proxmox_bind_unprivileged_lxc/
[cr0x.net]: https://cr0x.net/en/proxmox-lxc-bind-mount-permissions/

## Illustrating Permissions

### What the LXC sees

```bash
ls -an test
# output
-rw-r--r-- 1 0 0 0 May 24 15:41 test
```

### What the NFS server and the PVE host sees

```bash
ls -an test
# output
-rw-r--r-- 1 100000 100000 0 May 24 17:41 test
```
