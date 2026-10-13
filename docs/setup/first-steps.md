# First steps

You've got a working system, or a dev shell on a Mac. This gets you to
building the code.

## 1. Change the password

On NixOS builds (the SSD, VMs and the template), log in as `uweai` and open
**Konsole**:

```bash
passwd
mkdir -p ~/.config/ads && touch ~/.config/ads/password-changed
```

The second line stops the terminal reminding you.

## 2. Get online and up to date

Connect to wifi from the network icon. Then fetch the latest society
configuration whenever a lead says there's an update:

```bash
ads-update
```

(On a Mac dev shell there's nothing to update: `nix develop` always uses the
latest.)

## 3. Connect to GitHub

The code is on GitHub. Create a key and add it to your account:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"   # press Enter to accept the defaults
cat ~/.ssh/id_ed25519.pub
```

Copy the line it prints into GitHub → Settings → **SSH and GPG keys** → **New
SSH key**.

## 4. Get the code

```bash
git clone git@github.com:SethBennett2523/uwe-fsai-ws.git
cd uwe-fsai-ws
```

## 5. Enter your department's shell

Always build inside your department's shell. It has the exact ROS and
libraries everyone else builds against:

```bash
nix develop github:SethBennett2523/ads-nix#perception --accept-flake-config
```

Departments: `integration`, `perception`, `planning`, `slam`, `simulation`.

## 6. Build and run

On Linux (the SSD, a VM, or NixOS), build your department's packages, for
example:

```bash
colcon build --symlink-install --packages-up-to cone_detector
source install/setup.bash
ros2 pkg list | grep cone
```

Use the package names from your department's folder under `src/`. Not every
package in the workspace builds yet, so build yours rather than the whole
tree.

On a Mac shell there's no ROS, so run your department's Python directly, for
example scripts and training code. To run ROS nodes, use the VM.

## Getting help

Ask in the society chat, and say which guide you followed and the last
command you ran.
