variable "pve_source_iso_url" {
  type        = string
  default     = "https://enterprise.proxmox.com/iso/proxmox-ve_6.4-1.iso"
  description = "URL to download installation ISO image from."
}

variable "pve_source_iso_checksum" {
  type        = string
  default     = "sha256:ab71b03057fdeea29804f96f0ff4483203b8c7a25957a4f69ed0002b5f34e607"
  description = "Checksum to verify downloaded ISO image."
}

variable "pve_output_directory" {
  type        = string
  default     = null
  description = "Directory where builder will place resulting image."
}

variable "pve_image_disk_size" {
  type        = string
  default     = "40G"
  description = "Size of disk image for Proxmox installation."
}

variable "pve_upgrade_after_install" {
  type        = string
  default     = "NO"
  description = "Set if installation of Proxmox VE will be dist-upgraded after installation (YES/NO)."
  validation {
    condition     = var.pve_upgrade_after_install == "YES" || var.pve_upgrade_after_install == "NO"
    error_message = "Variable pve_upgrade_after_install accepts only YES/NO values."
  }
}

variable "pve_box_version" {
  type        = string
  description = "Release build with this version."
}

variable "pve_temp_root_password" {
  type        = string
  description = "Use this `secure` password to install Proxmox PVE."
  default     = "vagrant1234!@#$"
}
