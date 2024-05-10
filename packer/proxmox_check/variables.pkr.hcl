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
