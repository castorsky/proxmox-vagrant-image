packer {
  required_plugins {
    ansible = {
      version = "~> 1.1.1"
      source = "github.com/hashicorp/ansible"
    }
    qemu = {
      version = "~> 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1.1.2"
    }
  }
}