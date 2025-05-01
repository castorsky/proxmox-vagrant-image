pve_vagrant
=========

A simple role to configure default Proxmox VE installation to use it with Vagrant.

The goal of this role is to make the following changes:
- install the `sudo` package;
- create user `vagrant` with password `vagrant` and ability to use `sudo` without password prompt;
- add the insecure Vagrant public key to authorized keys of `vagrant` user;
- remove enterprise repositories for PVE and Ceph;
- add no-subscription PVE repository;
- set kernel parameter to name network interfaces in old style (ethX);
- configure network with predictable interface name `eth0`.

Requirements
------------

No special modules needed, just ansible dependencies.

Role Variables
--------------

There are a couple of options to configure:
 - `pve_vagrant__vagrant_key_url` sets URL where the insecure Vagrant public key can be found;
 - `pve_vagrant__system_upgrade` controls if OS is upgraded prior to packaging (accepts YES/NO string, passing boolean variables via Packer have a strange behavior).

Dependencies
------------

Collection `ansible.posix` needed to set the authorized SSH key.

Example Playbook
----------------

Using this role is as simple as:

    - hosts: all
      become: true
      roles:
        - pve_vagrant

License
-------

BSD

Author Information
------------------

Castor Sky (csky57@gmail.com)
