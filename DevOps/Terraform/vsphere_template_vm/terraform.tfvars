#Provider
vsphere_user     = ""
vsphere_password = ""
vsphere_server   = ""

#Infrastructure
vsphere_datacenter      = ""
vsphere_compute_cluster = ""

# HV2-datastore1
# HV2-datastore2
# Storage_5.46
# Storage_7.28 
vsphere_datastore = ""

# VL105
# VL102
# VL100
vsphere_network = ""

#VM
vm_template_name = "ubuntu24-base-template-small"
vm_guest_id      = "ubuntu64Guest"
vm_vcpu          = "2"
vm_memory        = "2048"
vm_ipv4_netmask  = ""
vm_ipv4_gateway  = ""
vm_dns_servers   = ["", ""]
vm_disk_label    = "disk0"
vm_disk_size     = "50"
vm_disk_thin     = "false"
vm_domain        = ""
vm_firmware      = "efi"

vms = {
  rocky_test_1 = {
    name  = ""
    vm_ip = ""
  }
  # ,
  # rocky_test_2 = {
  #   name  = ""
  #   vm_ip = ""
  # }
}
