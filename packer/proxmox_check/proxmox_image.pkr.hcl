source "qemu" "proxmox-qemu-image" {
  iso_checksum     = "none"
  iso_url          = "file://${var.pve_output_directory}/packer-proxmox-qemu-image"
  output_directory = "${var.pve_output_directory}_provision"

  disk_image         = true
  use_backing_file   = false
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
  qemuargs           = [
    # These options are from default Packer options fetched with PACKER_LOG=1
    # (custom `-device` options overwite defaul ones and leave VM without disk).
    ["-device", "virtio-scsi-pci,id=scsi0"],
    ["-device", "scsi-hd,bus=scsi0.0,drive=drive0"],
    # These are custom option to add QEMU guest agent
    ["-chardev", "socket,path=/tmp/qga.sock,server=on,wait=off,id=qga0"],
    ["-device", "virtio-serial"],
    ["-device", "virtserialport,chardev=qga0,name=org.qemu.guest_agent.0"]
  ]
  shutdown_command   = "echo 'packer' | shutdown -P now"

  ssh_username = "root"
  ssh_password = "vagrant"
  ssh_timeout  = "10m"

}

build {
  sources = ["source.qemu.proxmox-qemu-image"]

  provisioner "ansible" {
    playbook_file   = "./playbook.yml"
    use_proxy       = "false"
    extra_arguments = [
      "-e ansible_password=vagrant",
      "-e pve_vagrant__system_upgrade=${var.pve_upgrade_after_install}",
      "--diff"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      provider_override   = "libvirt"
      keep_input_artifact = false
      output = "${var.pve_output_directory}_box/packer_{{.BuildName}}_{{.Provider}}_{{.Architecture}}.box"
    }
  }
}
