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
  - [Step 2: Ensure Drivers Available](#step-2-ensure-drivers-available)
  - [Step 3: Create an LXC Container](#step-3-create-an-lxc-container)
  - [Step 4: Add Device Passthrough](#step-4-add-device-passthrough)
  - [Step 5: Start Container](#step-5-start-container)
  - [Step 6: Install Ollama](#step-6-install-ollama)
  - [Step 7: Update Ollama config](#step-7-update-ollama-config)
  - [Step 8: Run a model](#step-8-run-a-model)
- [FIxes](#fixes)
- [Unused content](#unused-content)
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

Expected output is

```less
[    0.346111] pci 0000:00:00.2: AMD-Vi: IOMMU performance counters supported
[    0.548479] perf/amd_iommu: Detected AMD IOMMU #0 (2 banks, 4 counters/bank).
```

### Step 2: Ensure Drivers Available

On the Proxmox host shell, run `ls -l /dev/dri`, and check output is

```bash
root@homelab-node-01:~# ls -l /dev/dri
total 0
drwxr-xr-x 2 root root         80 May 13 18:17 by-path
crw-rw---- 1 root video  226,   0 May 13 18:17 card0
crw-rw---- 1 root render 226, 128 May 13 18:17 renderD128
```

### Step 3: Create an LXC Container

Create a new Debian based LXC container:

- Set the container to unprivileged
  - No (privileged) if you need GPU access — GPU passthrough in LXC requires a privileged container
- **Unprivelged: NO**
- Cores: 4
- Memory: 8192 MB RAM (0 MB swap),
- Root Disk: 64 GB

Once created switch on nesting within Options.

From Proxmox host Shell add the following to `/etc/pve/lxc/<container number>.conf`

```bash
lxc.cgroup.devices.allow: c 226:* rwm
lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir
```

### Step 4: Add Device Passthrough

Next, shut down the container, then go to Resources, and check if /dev/dri/card0 and /dev/dri/renderD128 have already been passed through.
If they are, click each one, then click Edit, check Advanced at the bottom, and change the Mode to 0666. This gives complete read
and write access to all users in the container. Then, in Resources still, click Add, Device passthrough, and type /dev/kfd with a
mode of 0666 as well. This is the compute interface required for ROCm, and allows our container to use our GPU for
computation when running a local LLM. Finally, you also need to give your Ollama container more storage for downloading your models
and for installing ROCm.

### Step 5: Start Container

From console get IP address using `ip a` and add entry into DNS

### Step 6: Install Ollama

Install Ollama directly on the LXC host, using

```bash
apt update && apt upgrade -y
# Install gpu test tools
apt install -y radeontop vainfo
# Install zstd to extract Ollama archive
apt install -y curl zstd
# Install Ollama (https://docs.ollama.com/linux)
curl -fsSL https://ollama.com/install.sh | sh
# Install AMD GPU ROCm package
curl -L https://ollama.com/download/ollama-linux-amd64-rocm.tar.zst -o ollama-linux-amd64-rocm.tar.zst
tar -C /usr -xf ollama-linux-amd64-rocm.tar.zst
```

### Step 7: Update Ollama config

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
```

To see environment variable use `ollama serve --help`.

Restart Ollama

```bash
systemctl daemon-reload
systemctl restart ollama
```

Check Ollama

```bash
journalctl -u ollama --no-pager --follow --pager-end
```

### Step 8: Run a model

Run the smallet [qwen3.5](https://ollama.com/library/qwen3.5) model to test system

```bash
ollama run qwen3.5:0.8b --think=false "Where should I visit in Utrecht?"
```

## FIxes

see [test](https://markaicode.com/fix-ollama-gpu-detection-driver-configuration/)

Run ollama with verbose

```bash
ollama run llama2 --verbose
```

```bash
apt install pciutils

# 1. Confirm the OS sees your GPU
lspci | grep -i "vga\|nvidia\|amd"

# 2. Check if drivers are loaded
lsmod | grep nvidia      # NVIDIA
lsmod | grep amdgpu      # AMD

# 3. Driver-level GPU status
nvidia-smi               # NVIDIA
rocm-smi                 # AMD (if ROCm installed)

# 4. CUDA availability
nvcc --version

# 5. Verbose Ollama output
ollama serve --verbose


# Install ROCm

Based on [official instructions](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/install-methods/package-manager/package-manager-debian.html)

```bash
# Install dependencies
apt install gpg
# Package signing key
mkdir --parents --mode=0755 /etc/apt/keyrings
wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null

# Register ROCm packages
tee /etc/apt/sources.list.d/rocm.list << EOF
deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/7.2.3 noble main
deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/graphics/7.2.3/ubuntu noble main
EOF

tee /etc/apt/preferences.d/rocm-pin-600 << EOF
Package: *
Pin: release o=repo.radeon.com
Pin-Priority: 600
EOF
apt update

apt install amdgpu-lib
```

## Unused content

Here for reference for what not to do!

### Install ROCm

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

For reference about not what was done.

```bash
apt update && apt -y upgrade
apt install -y build-essential make
update-initramfs -u
# install Proxmox VE headers
apt install proxmox-headers-$(uname -r)
```

I did this but do not think required.

**Do not follow instruction to install `firmware-amd-graphics`.**

Add the following

```bash
lxc.apparmor.profile: unconfined
lxc.cgroup2.devices.allow: c 226:128 rwm
lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file
```
