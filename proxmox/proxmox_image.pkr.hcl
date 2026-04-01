locals {
  # Find out which version of Proxmox is building.
  version_parts = split(".", var.pve_box_version)
  major = parseint(local.version_parts[0], 10)
  minor = parseint(local.version_parts[1], 10)

  # True for versions >= 9.1 (e.g., 9.1.x, 9.2, 10.0, etc.)
  is_9_1_or_newer = local.major > 9 || (local.major == 9 && local.minor >= 1)

  # Number of tabs needed for different stages:
  license_tab_count = local.is_9_1_or_newer ? 4 : 3
  network_tab_count = local.is_9_1_or_newer ? 8 : 6
  license_tabs = join("", [for i in range(local.license_tab_count) : "<tab>"])
  network_tabs = join("", [for i in range(local.network_tab_count) : "<tab>"])
}

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
  qemuargs = [
    # These options are from default Packer options fetched with PACKER_LOG=1
    # (custom `-device` options overwite defaul ones and leave VM without disk).
    ["-device", "virtio-scsi-pci,id=scsi0"],
    ["-device", "scsi-hd,bus=scsi0.0,drive=drive0"],
    # These are custom option to add QEMU guest agent
    ["-chardev", "socket,path=/tmp/qga.sock,server=on,wait=off,id=qga0"],
    ["-device", "virtio-serial"],
    ["-device", "virtserialport,chardev=qga0,name=org.qemu.guest_agent.0"]
  ]
  shutdown_command = "echo 'packer' | shutdown -P now"

  ssh_username = "root"
  ssh_password = var.pve_temp_root_password
  ssh_timeout  = "10m"

  # Script to simulate manual installation
  boot_wait = "10s"
  boot_steps = [
    ["<enter><wait1m>", "Select GRUB option and wait 1 min for installer to boot"],
    ["${local.license_tabs}<enter><wait>", "Accept license"],
    ["<enter><wait>", "Leave disk setting with defaults"],
    ["united states<down><enter><wait><enter><tab>", "Use US locale and New York timezone"],
    ["<down><down><down><down><down><down><down><down><down><down>"],
    ["<down><down><down><down><down><down><down><down><down><down><enter><enter>"],
    ["<tab><tab><tab><enter><wait>"],
    [
      "${var.pve_temp_root_password}<tab>${var.pve_temp_root_password}<tab>vagrant@example.com<tab><tab><enter><wait>",
      "Input password and email (default email fails)"
    ],
    ["pve.example.com${local.network_tabs}<enter><wait><enter>", "Set only hostname, launch installation"],
    [
      "<wait3m>root<enter><wait>${var.pve_temp_root_password}<enter><wait3s>",
      "Wait 3 min for setup to complete, then install qemu-guest-agent"
    ],
    ["apt update; apt install -y qemu-guest-agent<enter><wait1m>"],
    ["systemctl enable --now qemu-guest-agent<enter>"]
  ]
}

build {
  sources = ["source.qemu.proxmox-qemu-image"]

  provisioner "ansible" {
    playbook_file = "${path.root}/playbook.yml"
    use_proxy     = "false"

    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_COLLECTIONS_PATHS=${path.root}/../.ansible/collections",
      "ANSIBLE_ROLES_PATH=${path.root}/../.ansible/roles"
    ]

    extra_arguments = [
      "-e ansible_password=${var.pve_temp_root_password}",
      "-e pve_vagrant__system_upgrade=${var.pve_upgrade_after_install}",
      "--diff"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      provider_override    = "libvirt"
      keep_input_artifact  = false
      vagrantfile_template = "${path.root}/vagrant_template.rb"
      output               = "${var.pve_output_directory}_box/{{.BuildName}}_v${var.pve_box_version}_{{.Provider}}_{{.Architecture}}.box"
    }
  }
}
