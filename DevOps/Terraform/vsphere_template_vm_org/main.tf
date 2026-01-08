resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.HV2-datastore1.id
  num_cpus         = 2
  memory           = 2048
  firmware         = data.vsphere_virtual_machine.ubuntu24-base-template-small.firmware
  guest_id         = data.vsphere_virtual_machine.ubuntu24-base-template-small.guest_id
  scsi_type        = data.vsphere_virtual_machine.ubuntu24-base-template-small.scsi_type

  network_interface {
    network_id = data.vsphere_network.vlan.id
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.ubuntu24-base-template-small.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.ubuntu24-base-template-small.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.ubuntu24-base-template-small.id
    customize {
      # DHCP
      network_interface {}

      # Static IP
      # network_interface {
      #   ipv4_address = ""
      #   ipv4_netmask = 24
      # }

      # ipv4_gateway = ""

      linux_options {
        host_name = var.vm_name
        domain    = var.vm_domain
      }
    }
  }
}
