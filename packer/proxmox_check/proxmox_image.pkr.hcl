source "qemu" "proxmox-qemu-image" {
  iso_checksum = "sha256:815a45f6f24cb7b5a6d1877e117cf05c00f3fcdf9f58bc97da1319ff7590d237"
  iso_url      = "file:///home/castor/VSCodeProjects/baklan/proxmox-vagrant-image/packer/proxmox/output-proxmox-qemu-image/packer-proxmox-qemu-image"

  disk_image         = true
  use_backing_file   = true
  disk_interface     = "virtio-scsi"
  disk_cache         = "none"
  disk_resize        = false
  disk_discard       = "unmap"
  disk_detect_zeroes = "unmap"
  format             = "qcow2"
  accelerator        = "kvm"
  headless           = false
  cpu_model          = "host"
  cores              = 2
  memory             = 2048
  net_device         = "virtio-net"

  ssh_username = "root"
  ssh_password = "vagrant"
  ssh_timeout  = "10m"

}

build {
  sources = ["source.qemu.proxmox-qemu-image"]

  provisioner "ansible" {
    playbook_file   = "./playbook.yml"
    use_proxy       = "false"
    extra_arguments = ["--extra-vars", "ansible_password=vagrant", "--diff"]
  }

  post-processors {
    post-processor "vagrant" {
      provider_override   = "libvirt"
      keep_input_artifact = true
    }
  }
}
