# Setting up your machine

Pick the guide that matches what you have. Each one goes from nothing to a
working system, and they all end up with the same tools and versions as
everyone else.

| You have | Your options | Guide |
|---|---|---|
| A Mac | Your department's dev shell, or a full Linux VM | [I have a Mac](mac.md) |
| A Windows or Linux PC or laptop | An external bootable SSD, or a VM | [I have a PC or laptop](pc.md) |
| NixOS already | Add the society config to yours | [I already use NixOS](nixos.md) |

All three finish with [First steps](first-steps.md): your password, your
department's shell, and building the code.

**Not sure?** If you're new to Linux and have a PC, the external SSD is the
closest to "a laptop that just works", and it never touches your existing
system. On a Mac, start with the dev shell and add the VM only if you need
to run ROS.

## What you'll be logging in as

Every graphical build has the KDE Plasma desktop and the user `uweai`, with
password `uwe-fsai`. That password is printed here, in public, so change it
the first time you log in.

## While the repository is private

The commands below fetch `github:SethBennett2523/ads-nix`, which only works
once the repository is public. Until then:

- On your own machine, add an SSH key to your GitHub account and use
  `git+ssh://git@github.com/SethBennett2523/ads-nix` wherever these guides
  say `github:SethBennett2523/ads-nix`.
- Installing from a USB stick or into a fresh VM won't have your key, so
  those routes need the repository to be public, or a drive made for you by
  a project lead.
