# I already use NixOS

You keep your own configuration and add the society's on top. Everything it
sets is a default, so anything in your config wins, and nothing of yours is
ever pushed to the society repository.

Pick the route that matches how your system is set up today:

- **A. You don't use flakes yet** (your config is `/etc/nixos/configuration.nix`).
- **B. You already have a flake.**

Both need flakes switched on. If `nix flake --help` errors, add this to your
`configuration.nix` and run `sudo nixos-rebuild switch` once first:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

## A. No flake yet: add a flake next to your config

Your existing `configuration.nix` and `hardware-configuration.nix` stay
exactly as they are; a small flake around them adds the society's setup.

### 1. Add the flake files

```bash
nix flake new -t github:SethBennett2523/ads-nix /tmp/uweai
sudo cp /tmp/uweai/flake.nix /tmp/uweai/local.nix /etc/nixos/
```

Change `system = "x86_64-linux";` in `/etc/nixos/flake.nix` if you're on ARM.

### 2. Name your machine

Your machine's name has to match in three places. Use your current hostname
(`hostname` prints it):

- `nixosConfigurations.my-machine` in `flake.nix`
- `networking.hostName` in `local.nix`
- `ads.base.updateFlake = "/etc/nixos#my-machine";` in `local.nix`

If your `configuration.nix` already sets `networking.hostName`, delete that
line from one of the two files.

### 3. Decide what to keep

The `developer` profile adds the `uweai` user and the Plasma desktop. If you
have your own user and desktop, uncomment these in `local.nix`:

```nix
ads.user.enable = false;
ads.desktop.enable = false;
```

You still get ROS, CAN, the editors and the Nix settings.

### 4. Build, try, then switch

Flakes only see files tracked by git, so track them first:

```bash
cd /etc/nixos
sudo git init && sudo git add -A
sudo nixos-rebuild build --flake .#my-machine --accept-flake-config
```

If that succeeds, try it without making it the boot default:

```bash
sudo nixos-rebuild test --flake .#my-machine --accept-flake-config
```

and if all is well:

```bash
sudo nixos-rebuild switch --flake .#my-machine --accept-flake-config
```

If anything goes wrong after a switch, reboot and pick the previous
generation from the boot menu. From now on, `ads-update` fetches the latest
society configuration and switches to it.

## B. You already have a flake

### 1. Add the input

In your `flake.nix` inputs:

```nix
ads-nix.url = "github:SethBennett2523/ads-nix";
```

If you already have `nix-ros-overlay` as an input, share it:
`ads-nix.inputs.nix-ros-overlay.follows = "nix-ros-overlay";`.

### 2. Import what you want

Either the whole developer set:

```nix
modules = [ inputs.ads-nix.nixosModules.developer ... ];
```

or individual pieces, each inert until enabled:

```nix
modules = [
  inputs.ads-nix.nixosModules.ros
  inputs.ads-nix.nixosModules.can
  { ads.ros.enable = true; ads.can.enable = true; }
];
```

| Module | Gives you |
|---|---|
| `base` | Nix settings and the ROS binary cache, editors, everyday tools, NetworkManager, `ads-update` |
| `users` | the `uweai` account (`ads.user.name` to rename) |
| `ros` | ROS 2 Jazzy desktop, Gazebo, colcon, vcstool (`ads.ros.distro` to change) |
| `desktop` | KDE Plasma, VSCodium, Firefox |
| `cuda` | NVIDIA driver and CUDA toolkit |
| `can` | SocketCAN, a `vcan0` virtual bus, can-utils |
| `remote-admin` | key-only SSH |

If your `nixpkgs` isn't the one the society pins, ROS may compile locally
instead of downloading. Making yours follow
`ads-nix/nixpkgs` avoids that, at the cost of using its revision.

### 3. Build and switch

```bash
nix flake update ads-nix
sudo nixos-rebuild build --flake .#<hostname> --accept-flake-config
sudo nixos-rebuild switch --flake .#<hostname> --accept-flake-config
```

## Keeping up to date

When a lead announces an update:

```bash
nix flake update ads-nix && sudo nixos-rebuild switch --flake .#<hostname>
```

(With route A, `ads-update` does both steps for you.)

## Check it works

```bash
ros2 --help
colcon --help
```

Then continue with [First steps](first-steps.md) to get and build the code.
