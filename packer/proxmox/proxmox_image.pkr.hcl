variable "proxmox_password" {
  type        = string
  default     = "supersecret"
  description = "User password to use when connecting to PVE API."
}

variable "proxmox_username" {
  type        = string
  default     = "apiuser@pve!token"
  description = "User with realm and optionally token name to use when connecting to PVE API."
}

variable "proxmox_node" {
  type        = string
  default     = "pve"
  description = "Use this PVE node to pack image."
}

variable "proxmox_url" {
  type        = string
  default     = "https://127.0.0.1:8006/api2/json"
  description = "Connect to PVE API with this URL."
}

source "proxmox-iso" "proxmox-image" {
  iso_file = "local:iso/proxmox-ve_8.2-1.iso"
  # These options for not existing ISO file
  # iso_url = https://enterprise.proxmox.com/iso/proxmox-ve_8.2-1.iso
  # iso_storage_pool = local
  # iso_download_pve = true
  unmount_iso = true

  # Script to simulate manual installation
  boot_wait = "20s"
  boot_command = [
    # Select GRUB option and wait for installer to boot 
    "<enter><wait1m>",
    # Accept license
    "<tab><tab><tab><enter><wait>",
    # Leave disk setting with defaults
    "<enter><wait>",
    # Use US locale and New York timezone
    "united states<down><enter><wait><tab><tab>",
    "<down><down><down><down><down><down><down><down><down><down>",
    "<down><down><down><down><down><down><down><down><down><down><enter><enter>",
    "<tab><tab><tab><enter><wait>",
    # Input password and email (default email fails)
    "vagrant<tab>vagrant<tab>vagrant@example.com<tab><tab><enter><wait>",
    # Leave network settings untouched, launch installation
    "<tab><tab><tab><tab><tab><tab><enter><wait><enter>"
  ]

  cores                    = 2
  sockets                  = 1
  insecure_skip_tls_verify = true
  memory                   = 2048
  os                       = "l26"
  scsi_controller          = "virtio-scsi-single"
  cpu_type                 = "host"
  disks {
    type         = "scsi"
    disk_size    = "40G"
    storage_pool = "local"
    cache_mode   = "writethrough"
    format       = "qcow2"
    discard      = true
    ssd          = true
  }
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  ssh_username         = "root"
  ssh_password         = "vagrant"
  template_description = "Template image for Proxmox VE host"
  template_name        = "proxmox-node-8.2"
  task_timeout         = "5m"
  ssh_timeout          = "10m"

  node        = var.proxmox_node
  username    = var.proxmox_username
  token       = var.proxmox_password
  proxmox_url = var.proxmox_url
}

build {
  sources = ["source.proxmox-iso.proxmox-image"]
}
