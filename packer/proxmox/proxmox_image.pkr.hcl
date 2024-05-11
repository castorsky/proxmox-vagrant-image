source "qemu" "proxmox-qemu-image" {
  iso_checksum     = var.pve_source_iso_checksum
  iso_url          = var.pve_source_iso_url
  output_directory = var.pve_output_directory

  disk_size          = var.pve_image_disk_size
  disk_interface     = "virtio-scsi"
  disk_cache         = "none"
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

  # Script to simulate manual installation
  boot_wait = "10s"
  boot_steps = [
    ["<enter><wait1m>", "Select GRUB option and wait 1 min for installer to boot"],
    ["<tab><tab><tab><enter><wait>", "Accept license"],
    ["<enter><wait>", "Leave disk setting with defaults"],
    ["united states<down><enter><wait><enter><tab>", "Use US locale and New York timezone"],
    ["<down><down><down><down><down><down><down><down><down><down>"],
    ["<down><down><down><down><down><down><down><down><down><down><enter><enter>"],
    ["<tab><tab><tab><enter><wait>"],
    ["vagrant<tab>vagrant<tab>vagrant@example.com<tab><tab><enter><wait>", "Input password and email (default email fails)"],
    ["pve.example.com<tab><tab><tab><tab><tab><tab><enter><wait><enter>", "Set only hostname, launch installation"],
    ["<wait3m>root<enter><wait>vagrant<enter><wait3s>", "Wait 3 min for setup to complete, then install qemu-guest-agent"],
    ["apt update; apt install -y qemu-guest-agent<enter><wait1m>"],
    ["systemctl enable --now qemu-guest-agent<enter>"]
  ]
}

build {
  sources = ["source.qemu.proxmox-qemu-image"]
  
  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    use_proxy     = "false"
    extra_arguments = [
      "-e ansible_password=vagrant",
      "-e pve_vagrant__system_upgrade=${var.pve_upgrade_after_install}",
      "--diff"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      provider_override    = "libvirt"
      keep_input_artifact  = false
      vagrantfile_template = "vagrant_template.rb"
      output               = "${var.pve_output_directory}_box/{{.BuildName}}_v${var.pve_box_version}_{{.Provider}}_{{.Architecture}}.box"
    }
  }
}
