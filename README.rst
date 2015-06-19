=====================
NAV virtual appliance
=====================

This repository contains scripts and configuration to generate a `Network
Administration Visualized`_ virtual appliance, using Packer_ and VirtualBox_.

Building
--------

To build and GPG-sign an appliance, just run the ``build.sh`` script.

Booting the appliance for the first time
----------------------------------------

* Log in as root and change the root password from ``navrocks`` to something
  else (using the ``passwd`` command)

* Edit ``/etc/aliases`` to add a decent email address to forward the root
  user's email to. Then run the ``newaliases`` command.

* Fix the network configuration (``/etc/network/interfaces``), if necessary,
  and restart the networking service using ``/etc/init.d/network restart``

* Add networks that should be allowed to talk to the appliance in
  ``/etc/hosts.allow`` (both clients to the NAV web interface and network
  equipment that sends SNMP traps)

* Set a proper hostname/domain name in the following files: ``/etc/hosts``,
  ``/etc/resolv.conf``, ``/etc/mailname`` and
  ``/etc/exim4/update-exim4.conf.conf``.


Operating System
----------------

The virtual appliance is based on Debian GNU/Linux, and the Debian packages
released by the NAV team at their `APT repository`_.

.. _`Network Administration Visualized`: https://nav.uninett.no/
.. _Packer: https://packer.io/
.. _VirtualBox: https://www.virtualbox.org/
.. _`APT repository`: https://nav.uninett.no/install-instructions/#debian
