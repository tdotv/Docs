output "VM_IP" {
  value = [for i, ipadr in vsphere_virtual_machine.turilskijo-test-vm : ipadr.guest_ip_addresses]
}
