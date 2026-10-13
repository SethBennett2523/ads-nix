# I have a Mac

There are two ways to work on a Mac. Most people want the first.

- **Your department's dev shell.** Your department's tools, running natively
  on macOS, in one command. No ROS: ROS through Nix isn't reliable on macOS.
  Good for perception and training work, planning and SLAM maths, tooling
  and docs.
- **A Linux VM.** The full system, including ROS, RViz and Gazebo, in a
  window. Use it when you need to run ROS nodes.

You can have both.

## Option 1: dev shell

### 1. Install Nix

Open Terminal and run:

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

Answer `y` to its questions and enter your Mac password when asked. Then
switch on the features these shells use, and allow the project's download
cache:

```bash
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
echo "trusted-users = root $USER" | sudo tee -a /etc/nix/nix.conf
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

**Close Terminal and open a new window** so it picks up Nix. Check it works:

```bash
nix --version
```

### 2. Enter your department's shell

Replace `perception` with your department: `integration`, `perception`,
`planning`, `slam` or `simulation`.

```bash
nix develop github:SethBennett2523/ads-nix#perception --accept-flake-config
```

The first time downloads everything, which takes a while. After that it
starts in seconds. You're in the shell when the prompt shows the
`ads-nix perception shell` message; `exit` leaves it.

### 3. Check it works

```bash
python3 -c "import numpy, scipy; print('ok')"
```

Perception's shell also has PyTorch and Ultralytics:

```bash
python3 -c "import torch, ultralytics; print(torch.__version__)"
```

Now continue with [First steps](first-steps.md) to get the code.

## Option 2: a Linux VM

You need about 70 GB free and at least 8 GB of RAM (16 GB is comfortable).

### 1. Install UTM and download NixOS

1. Install UTM from [mac.getutm.app](https://mac.getutm.app) (free).
2. From [nixos.org/download](https://nixos.org/download), under *NixOS: the
   Linux distribution*, download the **Minimal ISO image, 64-bit ARM**.

### 2. Create the VM

In UTM:

1. Click **+**, then **Virtualize**, then **Linux**.
2. Under *Boot ISO Image*, click **Browse** and pick the ISO you downloaded.
   Continue.
3. Memory: **4096 MB** (or 8192 if your Mac has 16 GB or more).
   CPU cores: **4**. Continue.
4. Storage: **64 GB**. Continue, skip shared directory, Continue.
5. Name it `uweai` and click **Save**.
6. Optional, for a smoother desktop: open the VM's settings, choose
   **Display**, and pick the emulated display card with *GPU Supported* in
   its name.

### 3. Install

1. Start the VM. It boots to a text prompt, already logged in as `nixos`.
   Networking works automatically.
2. Install the society's VM build onto the VM's disk:
   ```bash
   sudo nix --extra-experimental-features 'nix-command flakes' run --accept-flake-config \
     github:SethBennett2523/ads-nix#ads-install -- vm-aarch64 /dev/vda
   ```
   It shows the disk and asks you to type `/dev/vda` to confirm. The
   install downloads several GB, so give it time.
3. When it says *Done*, run `poweroff`.
4. In UTM, select the VM, find **CD/DVD** at the bottom of its summary, and
   choose **Clear**, so it boots from its disk instead of the ISO.

### 4. First boot

Start the VM. You'll get the Plasma login screen. Log in as `uweai` with
password `uwe-fsai`, then continue with [First steps](first-steps.md).
