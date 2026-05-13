# GPU Passthrough for Ollama on an LXC

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [System Specifications](#system-specifications)
  - [Host](#host)
  - [Host Software](#host-software)
  - [Container Software](#container-software)
- [Steps](#steps)
  - [Step 1: Enable IOMMU](#step-1-enable-iommu)
  - [Step 2: Install Build Tools](#step-2-install-build-tools)
  - [Step 2](#step-2)
- [Install Ollama](#install-ollama)
- [Install ROCm](#install-rocm)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Following instructions from [XDA-Developers][xda-developers], [Kextcache][kextcache] and [ServerMan][serverman] as they focus on passthrough the LXC.

Instructions from [Virtualization HowTo][virtualization-howto] where not followed as not for Proxmo 9.

[xda-developers]: https://www.xda-developers.com/self-hosted-ollama-proxmox-lxc-uses-amd-gpu/
[virtualization-howto]: https://www.virtualizationhowto.com/2025/05/how-to-enable-gpu-passthrough-to-lxc-containers-in-proxmox/
[kextcache]: https://kextcache.com/proxmox-lxc-amd-gpu-passthrough/
[serverman]: https://www.serverman.co.uk/ai/ollama/how-to-run-ollama-in-proxmox/

Started without having made any modifications to Proxmox host, and found that drivers were already present and working.

## System Specifications

### Host

[Minisforum MS-A2](https://www.minisforum.com/products/minisforum-ms-a2)

- CPU: AMD RYZEN 9 9955HX (Zen 5, 16 cores, 32 threads, 64M L3 cache, Mx Boost clock up to 5.4GHz)
- GPU: AMD Radeon 610M
- RAM: 64GB DDR5-5600 (SO-DIMM x2)

### Host Software

[Proxmox VE](https://pve.proxmox.com/wiki/Main_Page)

- Proxmox VE 9 (9.1.9)
- Kernel: 7.0.2-2-pve

### Container Software

- LXC Kernel: 7.0.2-2-pve
- OS: Debian 13

## Steps

### Step 1: Enable IOMMU

Ensure IOMMU is enabled on the host, by checking the following line
is in the file `/etc/default/grub` via the .

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on"
```

Verify IOMMU is active using

```bash
dmesg | grep -e DMAR -e IOMMU
```

Create an LXC Container and

- Download an Ubuntu 24.04 LXC template from the template library
- Create a new container: 4 cores, 8 GB RAM, 80 GB disk
- Set the container to unprivileged: No (privileged) if you need GPU access — GPU passthrough in LXC requires a privileged container
- Enable nesting under Features if you want Docker inside the container

### Step 2: Install Build Tools

```bash
apt update && apt -y upgrade
apt install -y build-essential make
update-initramfs -u
# install Proxmox VE headers
apt install proxmox-headers-$(uname -r)
```

I did this but do not think required.

**Do not follow instruction to install `firmware-amd-graphics`.**

### Step 2

On the Proxmox host shell, run `ls -l /dev/dri`, and check output is

```bash
root@homelab-node-01:~# ls -l /dev/dri
total 0
drwxr-xr-x 2 root root         80 May 13 18:17 by-path
crw-rw---- 1 root video  226,   0 May 13 18:17 card0
crw-rw---- 1 root render 226, 128 May 13 18:17 renderD128
```

Modify the file `/etc/pve/lxc/201.conf`

Remove the line `unprivileged: 1`

Add the following

```bash
lxc.apparmor.profile: unconfined
lxc.cgroup2.devices.allow: c 226:128 rwm
lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file
```

Next, shut down the container, then go to Resources, and check if /dev/dri/card0 and /dev/renderD128 have already been passed through.
If they are, click each one, then click Edit, check Advanced at the bottom, and change the Mode to 0666. This gives complete read
and write access to all users in the container. Then, in Resources still, click Add, Device passthrough, and type /dev/kfd with a
mode of 0666 as well. This is the compute interface required for ROCm, and allows our container to use our GPU for
computation when running a local LLM. Finally, you also need to give your Ollama container more storage for downloading your models
and for installing ROCm.

Install [AMD official][amdgpu] `amdgpu-install` script.

[amdgpu]: https://amdgpu-install.readthedocs.io/

## Install Ollama

Install Ollama directly on the LXC host, using

```bash
# Install zstd to extract Ollama archive
apt install zstd
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh
# Install AMD GPU ROCm package
curl -L https://ollama.com/download/ollama-linux-amd64-rocm.tgz -o ollama-linux-amd64-rocm.tgz
tar -C /usr -xzf ollama-linux-amd64-rocm.tgz
```

Add the following to `/etc/systemd/system/ollama.`, or use `systemctl edit ollama`.

From [Frame.work docs][frame-work]

[frame-work]: https://community.frame.work/t/quickstart-guide-ollama-with-gpu-support-no-rocm-needed/79186

Add the following to `/etc/systemd/system/ollama.service`

```bash
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_VULKAN=1"
Environment="OLLAMA_FLASH_ATTENTION=1"
Environment="OLLAMA_CONTEXT_LENGTH=32768"
```

Restart Ollama

```bash
systemctl daemon-reload
systemctl restart ollama
```

Check Ollama

```bash
journalctl -e -u ollama
```

## Install ROCm

Following [rocm][rocm] official instructions

[rocm]: https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/quick-start.html

On LXC host

```bash
# Register repositories
wget https://repo.radeon.com/amdgpu-install/7.2.3/ubuntu/noble/amdgpu-install_7.2.3.70203-1_all.deb
apt install ./amdgpu-install_7.2.3.70203-1_all.deb
apt update
# Install kernel driver
apt install "linux-headers-$(uname -r)"
apt install amdgpu-dkms
# Install ROCm
apt install python3-setuptools python3-wheel
usermod -a -G render,video $LOGNAME # Add the current user to the render and video groups
apt install rocm
```

Following [eastondev][eastondev]

[eastondev]: https://eastondev.com/blog/en/posts/ai/20260425-ollama-gpu-acceleration/

```bash
# Add AMD official repository
sudo apt update
sudo apt install amdgpu-install
sudo amdgpu-install --usecase=rocm

# Add yourself to render group
sudo usermod -aG render,video $USER

# Reboot to apply
sudo reboot
```
