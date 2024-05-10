source "qemu" "proxmox-qemu-image" {
  iso_checksum     = "md5:a9c326a264a0f1d7b9af76dc88e6c44f"
  iso_url          = "file:///home/castor/temp/output_proxmox/packer-proxmox-qemu-image"
  output_directory = "/home/castor/temp/output_proxmox_check"

  disk_image         = true
  use_backing_file   = true
  disk_interface     = "virtio-scsi"
  disk_cache         = "none"
  skip_resize_disk   = false
  disk_discard       = "unmap"
  disk_detect_zeroes = "unmap"
  format             = "qcow2"
  accelerator        = "kvm"
  headless           = false
  cpu_model          = "host"
  cores              = 2
  memory             = 2048
  net_device         = "virtio-net"
  shutdown_command   = "echo 'packer' | sudo -S shutdown -P now"

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
