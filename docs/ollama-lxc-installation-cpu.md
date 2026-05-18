# Ollama LXC Installation - CPU only

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [System Specifications](#system-specifications)
  - [Host](#host)
  - [Host Software](#host-software)
  - [Container Software](#container-software)
- [Create a shared folder for models](#create-a-shared-folder-for-models)
  - [Create directory on host](#create-directory-on-host)
- [Steps](#steps)
  - [Step 1: Create an LXC Container](#step-1-create-an-lxc-container)
  - [Step 2: Start Container](#step-2-start-container)
  - [Step 3: Install Ollama](#step-3-install-ollama)
  - [Step 4: Update Ollama config](#step-4-update-ollama-config)
  - [Step 5: Install llmfit](#step-5-install-llmfit)
  - [Step 6: Run a model](#step-6-run-a-model)
  - [Trouble Shooting](#trouble-shooting)

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

Add mount to containers via LXC config files, for example, `/etc/pve/lxc/201.conf`, add the ling

```bash
# host path, container mount point
mp0: /mnt/lxc-shares/ollama_models,mp=/mnt/ollama/models
```

With unproveliged containers this results in permission issues. Have not continued with the configuration.

## Steps

### Step 1: Create an LXC Container

- Create a new Debian based LXC container:
  - Cores: 8
  - Memory: 24576 MB RAM (0 MB swap),
  - Root Disk: 80 GB

### Step 2: Start Container

From console get IP address using `ip a` and add entry into DNS

### Step 3: Install Ollama

Install Ollama directly on the LXC host, using

```bash
apt update && apt upgrade -y
# Install Ollama dependencies
apt install -y curl zstd
# Install Ollama (https://docs.ollama.com/linux)
curl -fsSL https://ollama.com/install.sh | sh
```

### Step 4: Update Ollama config

From [Frame.work docs][frame-work]

[frame-work]: https://community.frame.work/t/quickstart-guide-ollama-with-gpu-support-no-rocm-needed/79186

Add the following to `/etc/systemd/system/ollama.service`, or use `systemctl edit ollama`.

```bash
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_VULKAN=1"
Environment="OLLAMA_FLASH_ATTENTION=1"
Environment="OLLAMA_CONTEXT_LENGTH=12288"
```

Restart Ollama

```bash
systemctl daemon-reload
systemctl restart ollama
```

Check Ollama

```bash
journalctl -u ollama --no-pager --follow --pager-end
```

### Step 5: Install llmfit

The [llmfit project][llmfit] provides a tool which assist identifying models suitable for the system. Install using

```bash
curl -fsSL https://llmfit.axjns.dev/install.sh | sh
```

[llmfit]: https://github.com/AlexsJones/llmfit

### Step 6: Run a model

Run the smallet [qwen3.5](https://ollama.com/library/qwen3.5) model to test system

```bash
ollama run qwen3.5:0.8b --think=false "Where should I visit in Utrecht?"
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
