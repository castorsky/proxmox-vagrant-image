source "proxmox-clone" "proxmox-image-test" {
  clone_vm_id              = 111
  cores                    = 2
  sockets                  = 1
  insecure_skip_tls_verify = true
  memory                   = 2048
  os                       = "l26"
  scsi_controller          = "virtio-scsi-single"
  cpu_type                 = "host"

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  ssh_username         = "root"
  ssh_password         = "vagrant"
  template_description = "Template image for Proxmox VE host"
  template_name        = "proxmox-node-8.2-test"
  task_timeout         = "5m"
  ssh_timeout          = "10m"

  node        = var.proxmox_node
  username    = var.proxmox_username
  token       = var.proxmox_password
  proxmox_url = var.proxmox_url
}

build {
  sources = ["source.proxmox-clone.proxmox-image-test"]
  post-processors {
    post-processor "vagrant" {
      provider_override = "libvirt"
    }
  }
}
