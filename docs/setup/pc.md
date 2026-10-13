# I have a PC or laptop

Two options. Neither touches Windows or anything else already on the machine.

- **An external bootable SSD.** The society's system lives on a USB drive.
  Plug it in, pick it at startup, and the laptop runs NixOS at full speed;
  unplug it and the laptop is exactly as before. Recommended.
- **A VM.** The same system in a window on your current OS. Easier to start,
  but slower, and GPU work (CUDA, Gazebo) is limited.

## Option 1: external bootable SSD

### What you need

- A USB 3 external SSD, 128 GB or more. **Everything on it will be erased.**
  A memory stick works, but is much slower.
- A USB stick of 4 GB or more for the installer. It gets erased too.
- Internet access (wifi is fine).

### 1. Prepare Windows

Skip this if the laptop doesn't run Windows.

1. **Get your BitLocker recovery key** from
   [aka.ms/myrecoverykey](https://aka.ms/myrecoverykey) and keep it
   somewhere other than this laptop. Changing Secure Boot (step 3) can make
   Windows ask for it on the next start.
2. **Turn off Fast Startup:** Control Panel → Power Options → *Choose what the
   power buttons do* → *Change settings that are currently unavailable* →
   untick **Turn on fast startup** → Save.

### 2. Make the installer stick

1. From [nixos.org/download](https://nixos.org/download), under *NixOS: the
   Linux distribution*, download the **Graphical ISO image, 64-bit
   Intel/AMD**.
2. Write it to the small USB stick:
   - **Windows:** [Rufus](https://rufus.ie). Select the stick and the ISO,
     click Start, and choose **DD Image mode** when asked.
   - **macOS:** [balenaEtcher](https://etcher.balena.io).
   - **Linux:** `sudo dd if=nixos-*.iso of=/dev/sdX bs=4M status=progress conv=fsync`,
     with `/dev/sdX` being the stick.

### 3. Turn off Secure Boot

The society's system isn't signed for Secure Boot, so it won't start with it
on.

1. Restart and press the setup key as the laptop starts. It's usually
   **F2**, **Del**, **F10** or **Esc**, and often shown briefly on screen.
2. Find **Secure Boot** (often under *Security* or *Boot*), set it to
   **Disabled**, then save and exit.

### 4. Boot the installer

1. Plug in the installer stick and restart.
2. Press the **boot menu key** as it starts: Dell and Lenovo **F12**, HP
   **F9**, ASUS **Esc** or **F8**, Acer **F12**, MSI **F11**.
3. Choose the USB stick (it may be listed with *UEFI* in front of it).
4. Pick the first entry in the NixOS menu. You'll arrive at a Plasma
   desktop.

### 5. Install onto the SSD

1. Connect to wifi from the network icon in the bottom-right.
2. Plug in the external SSD.
3. Open **Konsole** from the application menu and list the drives:
   ```bash
   lsblk -d -o NAME,SIZE,MODEL,TRAN
   ```
   Your SSD is the one with `usb` under TRAN and the right size, for example
   `sdb`. **Make sure** it isn't the laptop's own disk (usually `nvme0n1` or
   `sda` with no `usb`) or the installer stick.
4. Install. Use `dev-x86-cuda` instead of `dev-x86` if the laptop has an
   NVIDIA graphics card, and your SSD's name instead of `sdb`:
   ```bash
   sudo nix --extra-experimental-features 'nix-command flakes' run --accept-flake-config \
     github:SethBennett2523/ads-nix#ads-install -- dev-x86 /dev/sdb
   ```
   It shows the drive and asks you to type its name (`/dev/sdb`) to confirm.
   It then downloads several GB straight onto the SSD, so give it time.
5. When it says *Done*, shut down from the application menu.

### 6. First boot

1. Remove the installer stick, keep the SSD plugged in, and turn the laptop
   on with the boot menu key again.
2. Choose the SSD. The first start takes a little longer while the drive
   grows to its full size.
3. At the Plasma login screen, log in as `uweai` with password `uwe-fsai`.

From now on, pick the SSD from the boot menu whenever you want to work on
the car's software. Without it plugged in, the laptop starts as normal. To
skip the boot menu, you can put USB first in the firmware's boot order.

Continue with [First steps](first-steps.md).

## Option 2: a VM

You need about 70 GB free and 8 GB of RAM or more. These steps use
VirtualBox on Windows; on Linux, see *Linux host* below.

### 1. Get the software

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (free).
2. Download the NixOS **Graphical ISO image, 64-bit Intel/AMD** from
   [nixos.org/download](https://nixos.org/download).

### 2. Create the VM

In VirtualBox, click **New**:

1. Name `uweai`. ISO Image: the NixOS ISO. Type **Linux**, version **Other
   Linux (64-bit)**. Tick **Skip Unattended Installation**.
2. Hardware: **4096 MB** memory (8192 if you have 16 GB or more), **4**
   CPUs, and tick **Enable EFI**. This matters: without it the VM won't
   boot after installing.
3. Hard disk: **64 GB**. Finish.
4. Open the VM's **Settings** → **Display**, and set video memory to
   **128 MB**.

### 3. Install

1. Start the VM and pick the first NixOS menu entry. You'll get a Plasma
   desktop. Networking works automatically.
2. Open **Konsole** and run:
   ```bash
   sudo nix --extra-experimental-features 'nix-command flakes' run --accept-flake-config \
     github:SethBennett2523/ads-nix#ads-install -- vm-x86 /dev/sda
   ```
   Type `/dev/sda` to confirm. The install downloads several GB.
3. When it says *Done*, shut down. In the VM's **Settings** → **Storage**,
   select the ISO under the optical drive and **Remove Disk from Virtual
   Drive**.

### 4. First boot

Start the VM. Log in as `uweai` with password `uwe-fsai`, then continue with
[First steps](first-steps.md).

### Linux host

Use **virt-manager** (or GNOME Boxes) with the same ISO, memory, CPUs and
disk. In virt-manager, tick **Customize configuration before install** and
set **Firmware** to **UEFI** on the Overview page. The disk is `/dev/vda`
rather than `/dev/sda`.

If you already have Nix, you can skip the installer and run a throwaway VM
straight away:

```bash
nixos-rebuild build-vm --flake github:SethBennett2523/ads-nix#vm-x86 --accept-flake-config
./result/bin/run-vm-x86-vm
```
