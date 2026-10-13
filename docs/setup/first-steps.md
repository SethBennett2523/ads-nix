# First steps

You've got a working system, or a dev shell on a Mac. This gets you to
building the code.

## 1. Change the password

On the SSD or a VM, log in as `uweai`, open the application menu (bottom
left), search for **Konsole** and open it. Then type:

```bash
passwd
```

It asks for the current password (`uwe-fsai`), then your new one twice.
**Nothing appears as you type**; that's normal. Then run this, which stops
the terminal reminding you:

```bash
mkdir -p ~/.config/ads && touch ~/.config/ads/password-changed
```

<details>
<summary>▶ How do I use the terminal (Konsole)?</summary>

Click in the window and type, or paste, a command, then press **Enter**.
To paste in Konsole, use **Ctrl + Shift + V**, or right-click → Paste. The
**Up arrow** brings back your last command. A command has finished when you
see a line ending in `$` again.

</details>

## 2. Get online and up to date

Connect to wifi from the network icon. Then fetch the latest society
configuration whenever a lead says there's an update:

```bash
ads-update
```

(On a Mac dev shell there's nothing to update: `nix develop` always uses the
latest.)

## 3. Connect to GitHub

The code is on GitHub. You need a free GitHub account, and a *key* so your
computer can prove it's you. Create one:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"   # press Enter to accept the defaults
cat ~/.ssh/id_ed25519.pub
```

Copy the whole line it prints (it starts `ssh-ed25519`). On
[github.com](https://github.com), click your picture (top right) →
**Settings** → **SSH and GPG keys** → **New SSH key**, paste it into *Key*,
give it a title like "uweai SSD", and click **Add SSH key**.

<details>
<summary>▶ What's an SSH key?</summary>

A pair of matching files: a private one that stays on your computer, and a
public one (the line you copied) that you give to GitHub. Together they let
GitHub recognise your computer without a password. Never share the private
one (`id_ed25519`, without `.pub`).

</details>

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
