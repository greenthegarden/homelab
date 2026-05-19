# Ollama Unprivileged LXC Installation

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Resources](#resources)
- [System Specifications](#system-specifications)
  - [Host](#host)
  - [Host Software](#host-software)
  - [Container Software](#container-software)
- [Create a shared folder for models](#create-a-shared-folder-for-models)
  - [Create directory on host](#create-directory-on-host)
- [CPU Only - no GPU Passthrough](#cpu-only---no-gpu-passthrough)
  - [Step 1: Create an LXC Container](#step-1-create-an-lxc-container)
  - [Step 2: Install Ollama](#step-2-install-ollama)
- [GPU Passthrough](#gpu-passthrough)
  - [Step 1: Enable IOMMU](#step-1-enable-iommu)
  - [Create an LXC Container](#create-an-lxc-container)
  - [Simple configuration for GPU passthrough](#simple-configuration-for-gpu-passthrough)
  - [Complex configuration for GPU passthrough](#complex-configuration-for-gpu-passthrough)
    - [Manage Group IDs](#manage-group-ids)
- [Configuring and Running Ollama](#configuring-and-running-ollama)
  - [Update Ollama config](#update-ollama-config)
  - [Install llmfit](#install-llmfit)
  - [Running a model](#running-a-model)
  - [Trouble Shooting](#trouble-shooting)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Resources

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
- GPU: AMD Radeon 610M (gfx1036)
- RAM: 64GB DDR5-5600 (SO-DIMM x2)

### Host Software

[Proxmox VE](https://pve.proxmox.com/wiki/Main_Page)

- Proxmox VE 9 (9.1.14)
- Kernel: 7.0.2-4-pve

### Container Software

- LXC Kernel: 7.0.2-4-pve
- OS: Debian 13

## Create a shared folder for models

### Create directory on host

To share models between multiple instances of Ollama, use a [shared folder on the Proxmox host][mounts-guide].

[mounts-guide]: https://blog.kreativhub.tech/mastering-mounts-and-storage-permissions-in-proxmox-lxc-a-guide-to-uid-gid-mapping/
[pve-docs-bind_mount]: https://pve.proxmox.com/pve-docs/pve-admin-guide.html#_bind_mount_points

Should use /mnt for as [host point][pve-docs-bind_mount]:

```bash
# Via Proxmox server shell
mkdir -p /mnt/lxc-shares/ollama_models
chmod -R 755 /mnt/lxc-shares
```

Add mount to containers via LXC config files, for example, `/etc/pve/lxc/201.conf`, add the line

```bash
# host path, container mount point
mp0: /mnt/lxc-shared/ollama_models,mp=/mnt/ollama/models
```

With unproveliged containers this results in permission issues. Have not continued with the configuration.

## CPU Only - no GPU Passthrough

### Step 1: Create an LXC Container

An LXC with large compute and memory resource is required.

- Create a new Debian based LXC container:
  - Cores: 8
  - Memory: 24576 MB RAM (0 MB swap),
  - Root Disk: 80 GB

Add record in DNS to IP of host.

### Step 2: Install Ollama

Start the LXC and install Ollama directly on the LXC host, using

```bash
apt update && apt upgrade -y
# Install Ollama dependencies
apt install -y curl zstd
# Install Ollama (https://docs.ollama.com/linux)
curl -fsSL https://ollama.com/install.sh | sh
```

## GPU Passthrough

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

Expected output is

```less
[    0.346111] pci 0000:00:00.2: AMD-Vi: IOMMU performance counters supported
[    0.548479] perf/amd_iommu: Detected AMD IOMMU #0 (2 banks, 4 counters/bank).
```

On the Proxmox host shell, run `ls -l /dev/dri`, and check output is

```bash
root@homelab-node-01:~# ls -l /dev/dri
total 0
drwxr-xr-x 2 root root         80 May 13 18:17 by-path
crw-rw---- 1 root video  226,   0 May 13 18:17 card0
crw-rw---- 1 root render 226, 128 May 13 18:17 renderD128
```

### Create an LXC Container

Container can have minimal resources as using the GPU for processing

- Create a new Debian based LXC container:
  - Cores: 4
  - Memory: 4096 MB RAM (0 MB swap),
  - Root Disk: 8 GB

### Simple configuration for GPU passthrough

Guidance from [psmarchin.dev][psmarchin-dev] is much simpler

[psmarchin-dev]: https://psmarcin.dev/posts/how-to-configure-gpu-passthrough-for-linux-containers-on-proxmox/

Use UI to add device pass through

- renderD128
  - device path: `/dev/dri/renderD128`
  - GID in CT: 992 (found using `cat /etc/group | grep render` from container)
  - Access mode in CT: 0660
- card0
  - device path: `/dev/dri/card0`
  - GID in CT: 44 (found using `cat /etc/group | grep video` from container)
  - Access mode in CT: 0660
-

Check access using

```bash
ls -lah /dev/dri
```

Installed Ollama directly on LXC using the following, and install script automatically detected GPU
available and install ROCm package.

```bash
apt update && apt upgrade -y
# Install Ollama dependencies
apt install -y curl zstd
# Install Ollama (https://docs.ollama.com/linux)
curl -fsSL https://ollama.com/install.sh | sh
```

### Complex configuration for GPU passthrough

Based on instructions from Jim's Garage via [YouTube][youtube-jims-garage-gpu] and [Github][github-jims-garage-gpu]:

[youtube-jims-garage-gpu]: https://www.youtube.com/watch?v=0ZDr5h52OOE
[github-jims-garage-gpu]: https://github.com/JamesTurland/JimsGarage/tree/main/GPU_passthrough

#### Manage Group IDs

From Proxmox Host Shell

```bash
# Via Proxmox server shell
cat /etc/group
```

Check for groups `video` and `render` which will need to give LXC access to

```bash
video:x:44:
render:x:993:
```

Amend file `/etc/subgid`, which was originally

```bash
root:100000:65536
```

From Proxmox Host Shell

```bash
# Via Proxmox server shell
vi /etc/subgid
# to add two lines for video and render groups
root:44:1
root:993:1
```

File now

```bash
root:100000:65536
root:44:1
root:993:1
```

Edit LXC config, `vi /etc/pve/lxc/205.conf`

Original file

```bash
arch: amd64
cores: 4
features: nesting=1
hostname: lxc-ollama-gpu
memory: 4096
net0: name=eth0,bridge=vmbr0,firewall=1,hwaddr=BC:24:11:F4:2B:AF,ip=dhcp,type=veth
ostype: debian
rootfs: local-lvm:vm-205-disk-0,size=8G
swap: 0
unprivileged: 1
```

Update to

```bash
arch: amd64
cores: 4
features: nesting=1
hostname: lxc-ollama-gpu
memory: 4096
net0: name=eth0,bridge=vmbr0,firewall=1,hwaddr=BC:24:11:F4:2B:AF,ip=dhcp,type=veth
ostype: debian
rootfs: local-lvm:vm-205-disk-0,size=8G
swap: 0
unprivileged: 1
lxc.cgroup2.devices.allow: c 266:0 rwm
lxc.cgroup2.devices.allow: c 266:128 rwm
lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file
lxc.idmap: u 0 100000 65536
lxc.idmap: g 0 100000 44
lxc.idmap: g 44 44 1
lxc.idmap: g 45 100045 948
lxc.idmap: g 993 993 1
lxc.idmap: g 994 100994 65428
```

Where `lxc.cgroup2.devices` are the devices attached to the host, at `/dev/dri`, with the group IDs.

The lines `lxc.cgroup2.devices.allow` passthrough the device, and `lxc.mount.entry` create the mount point.

Recall

```bash
video:x:44:
render:x:993:
```

The lines `lxc.idmap` are as follows:

- `lxc.idmap: u 0 100000 65536`: map UIDs 0-65535 (LXC namespace) to 100000-165535 (host namespace)
- `lxc.idmap: g 0 100000 44`: map GIDs 0-43 (LXC namespace) to 100000-100043 (host namespace)
- `lxc.idmap: g 44 44 1`: map GID 44 to be the same in both namespaces
- `lxc.idmap: g 45 100045 948`: map GIDs 45-992 (LXC namespace) to 100045-100992 (host namespace)
  - 992 is the group before the render group (993) in LXC namespace
  - 948 = 993 (render group in LXC) - 45 (start group for this mapping)
- `lxc.idmap: g 993 993 1`: map GID 993 (render in LXC) to 107 (render in host)
- `lxc.idmap: g 994 100994 65428`: map GIDs 994-65536 (LXC namespace) to 100994-165535 (host namespace)
  - 994 is the group after the render group (993) in LXC namespace
  - 64542 = 65536 (max gid) - 994 (start group for this mapping)

Change group assignment on the Proxmox host for the render and video groups

```bash
usermod -aG render,video root
```

Start the container and check, the device is found

```bash
# From the container console
ls -l /dev/dri
# See that `renderD128` is present
# TO find GID
stat -c '%g' /dev/dri/renderD128
```

Use lspci

```bash
# From the container console
apt update && apt install -y pciutils
lspci
# See the VGA is present
```

Start the LXC and install Ollama directly on the LXC host, using

```bash
apt update && apt upgrade -y
# Install Ollama dependencies
apt install -y curl zstd
# Install Ollama (https://docs.ollama.com/linux)
curl -fsSL https://ollama.com/install.sh | sh
# Install AMD GPU ROCm package
curl -L https://ollama.com/download/ollama-linux-amd64-rocm.tar.zst -o ollama-linux-amd64-rocm.tar.zst
tar -C /usr -xf ollama-linux-amd64-rocm.tar.zst
```

## Configuring and Running Ollama

### Update Ollama config

From [Frame.work docs][frame-work]

[frame-work]: https://community.frame.work/t/quickstart-guide-ollama-with-gpu-support-no-rocm-needed/79186

Add the following to `/etc/systemd/system/ollama.service`, or use `systemctl edit ollama`.

```bash
[Service]
Environment="OLLAMA_DEBUG=1"
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_VULKAN=1"
Environment="OLLAMA_NO_CLOUD=1"
Environment="OLLAMA_FLASH_ATTENTION=1"
#Environment="OLLAMA_CONTEXT_LENGTH=32768"
Environment="HSA_OVERRIDE_GFX_VERSION=10.3.0"
```

To see the list of supported environment variables use `ollama serve --help`.

Restart Ollama

```bash
systemctl daemon-reload
systemctl restart ollama
```

Check Ollama logs

```bash
journalctl -u ollama --no-pager --follow --pager-end
```

### Install llmfit

The [llmfit project][llmfit] provides a tool which assist identifying models suitable for the system. Install using

```bash
curl -fsSL https://llmfit.axjns.dev/install.sh | sh
```

[llmfit]: https://github.com/AlexsJones/llmfit

### Running a model

Run the smallet [qwen3.5](https://ollama.com/library/qwen3.5) model to test system

```bash
ollama run qwen3.5:0.8b --think=false "Where should I visit in Utrecht?"
```

```bash
ollama run qwen3.5:9b --think=false "Where should I visit in Utrecht?"
ollama run qwen2.5-coder:7b --think=false "Create Hello, World app in Python"
ollama run qwen3.5:0.8b --think "Where should I visit in Utrecht?"
```

[Models to run](https://www.deployhq.com/blog/running-generative-ai-models-with-ollama-and-open-webui-using-deployhq):

- General: qwen3.5:9b, llama3.18b
- Coding: qwen2.5-coder:7b
- RAG over documents: llama3.1:8b

To stop thinking for qwen models, in Open-WebUI:

- clone the model (Admin Panel -> Settings -> Models) - More -> Clone
- Within `Advanced Params -> Show` set `think (Ollama)` to `Off`
- Save model

### Trouble Shooting

Ollama [trouble shooting guide][ollama-tsg] offers details about debugging.

[ollama-tsg]: https://docs.ollama.com/troubleshooting
