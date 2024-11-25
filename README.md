# Proxmox Vagrant Image

Collection of Packer/Ansible configs to build minimal Proxmox Virtual Environment image for Vagrant.

## Prerequisites

1. Always check on builer host if it supports nested virtualization: https://pve.proxmox.com/wiki/Nested_Virtualization.
2. Install Packer:
    1. Generic installation: https://developer.hashicorp.com/packer/install#linux
    2. openSUSE installation: `opi packer`
3. Install Ansible to the work directory:
```shell
python3 -m venv .venv
source .venc/bin/activate
pip install -r requirements.txt
ansible-galaxy install -r requirements.yml
```
4. openSUSE sometimes needs `qemu-ui-gtk` to be installed separately. Otherwise, the Packer can fail with error `Qemu stderr: qemu-system-x86_64: Display 'gtk' is not available`. And `sshpass` to login into box without public key.
```shell
zypper in qemu-ui-gtk sshpass
```

## Executing

#### Simple
```shell
cd packer
packer init .
cd proxmox
packer validate -var-file=variants/version82.pkrvars.hcl .
packer build -var-file=variants/version82.pkrvars.hcl .
```

#### Explained

Config file `./packer/config.pkr.hcl` contains list of Packer plugins needed to build Vagrant image for Proxmox VE (ansible, qemu, vagrant). Command `packer init .` reads this config and installs plugins.

Directory `./packer/proxmox` contains all other configs and scripts to make actual build of image:
- Ansible role `pve_vagrant` ([short documentation](./packer/proxmox/pve_vagrant/README.md)) that makes provisioning of installed system in the VM;
- Ansible playbook that triggers role `pve_vagrant`;
- Vagrant template `vagrant_template.rb` which will be embedded into Vagrant box and will be used as default config for box;
- directory `variants` holds collection of Packer variable files to configure build proccess;
- files `proxmox_image.pkr.hcl` and `variables.pkr.hcl` are the actual Packer config that is executed when command `packer build .` triggered.

## License

BSD
