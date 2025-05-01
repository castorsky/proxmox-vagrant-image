# Proxmox Vagrant Image

Collection of Packer/Ansible configs to build minimal Proxmox Virtual Environment image for Vagrant.

## Prerequisites

1. Always check on the builder host if it supports nested virtualization: https://pve.proxmox.com/wiki/Nested_Virtualization.
2. Install Packer:
    1. Generic installation: https://developer.hashicorp.com/packer/install#linux
    2. openSUSE installation: `opi packer`
3. Install Ansible to the work directory:
   ```shell
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ansible-galaxy install -r requirements.yml
   ```
4. openSUSE sometimes needs the `qemu-ui-gtk` package to be installed separately. Otherwise, the Packer can fail with error `Qemu stderr: qemu-system-x86_64: Display 'gtk' is not available`. And `sshpass` to login into box without a public key.
```shell
zypper in qemu-ui-gtk sshpass
```

## Executing

### Simple

```shell
packer init .
packer validate -var-file=proxmox/variants/version84.pkrvars.hcl proxmox/
packer build -var-file=proxmox/variants/version84.pkrvars.hcl proxmox/
```

### Explained

Config file `config.pkr.hcl` contains a list of Packer plugins needed to build Vagrant image for Proxmox VE (ansible, qemu, vagrant).

Command `packer init .` reads this config and installs plugins.

Directory `proxmox/` contains all other configs and scripts to make actual build of image:
- Ansible role `pve_vagrant` ([short documentation](./packer/proxmox/pve_vagrant/README.md)) that makes provisioning of the installed system in the VM;
- Ansible playbook that triggers role `pve_vagrant`;
- Vagrant template `vagrant_template.rb` which will be embedded into Vagrant box and will be used as default config for box;
- directory `variants` holds a collection of Packer variable files to configure the building process;
- files `proxmox_image.pkr.hcl` and `variables.pkr.hcl` are the actual Packer config that is executed when command `packer build proxmox/` triggered.

## Testing

Assume that the building process finished successfully with a similar output:
```
==> Builds finished. The artifacts of successful builds are:
--> qemu.proxmox-qemu-image: 'libvirt' provider box: /home/castor/temp/output_proxmox_v84_box/proxmox-qemu-image_v8.4.0_libvirt_amd64.box
```

Add box image from the local source and create VM with vagrant:
```shell
vagrant box add /home/castor/temp/output_proxmox_v84_box/proxmox-qemu-image_v8.4.0_libvirt_amd64.box --name proxmox-qemu
mkdir -p ~/temp/proxmox-test-image && cd ~/temp/proxmox-test-image
vagrant init proxmox-qemu
vagrant up
vagrant ssh
```

## License

BSD
