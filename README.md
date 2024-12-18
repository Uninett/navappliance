# NAV virtual appliance

This repository contains scripts and configuration to generate a [Network
Administration Visualized](https://nav.uninett.no/) virtual appliance, using
[Packer](https://packer.io/) and [VirtualBox](https://www.virtualbox.org/).

## Building

Appliances are built automatically by GitHub workflows in this repository.
Successful builds are tagged and published as releases.  Check the [Releases
page](https://github.com/Uninett/navappliance/releases) for the latest build.

To build an appliance manually, run the `build.sh` script.

## Booting the appliance for the first time

The appliance should work out-of-the-box on first boot, but you may want to
adapt it to your needs for a smoother experience:

* Log in as root and change the root password from `navrocks` to something
  else (using the `passwd` command)

* Edit `/etc/aliases` to add a decent email address to forward the root
  user's email to. Then run the `newaliases` command.

* Fix the network configuration (`/etc/network/interfaces`), if necessary,
  and restart the networking service using `systemctl restart networking`

* Add networks that should be allowed to talk to the appliance in
  `/etc/hosts.allow` (both clients to the NAV web interface and network
  equipment that sends SNMP traps)

* Set a proper hostname/domain name in the following files: `/etc/hosts`,
  `/etc/resolv.conf`, `/etc/mailname` and
  `/etc/exim4/update-exim4.conf.conf`.

* The timezone of NAV and Graphite is set to `Europe/Oslo`. You may wish to
  change this in `/etc/nav/nav.conf` and
  `/etc/graphite/local_settings.py` to fit with your actual timezone.

## Operating System

The virtual appliance is based on Debian GNU/Linux 11 (Bullseye), and the Debian
packages released by the NAV team at their [APT
repository](https://nav.uninett.no/install-instructions/#debian).
