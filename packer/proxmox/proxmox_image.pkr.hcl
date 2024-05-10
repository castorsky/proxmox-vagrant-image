source "qemu" "proxmox-qemu-image" {
  iso_checksum     = "sha256:d99d182a0df4ba94c27668d3e33d14cc286d775a7bdf571a86c24ea522009e93"
  iso_url          = "file:///home/castor/Downloads/proxmox-ve_8.2-1.iso"
  output_directory = "/home/castor/temp/output_proxmox"

  disk_size          = "40G"
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
  shutdown_command   = "echo 'packer' | sudo -S shutdown -P now"

  ssh_username = "root"
  ssh_password = "vagrant"
  ssh_timeout  = "10m"

  # Script to simulate manual installation
  boot_wait = "20s"
  boot_steps = [
    ["<enter><wait1m>", "Select GRUB option and wait 1 min for installer to boot"],
    ["<tab><tab><tab><enter><wait>", "Accept license"],
    ["<enter><wait>", "Leave disk setting with defaults"],
    ["united states<down><enter><wait><tab><tab>", "Use US locale and New York timezone"],
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
}
