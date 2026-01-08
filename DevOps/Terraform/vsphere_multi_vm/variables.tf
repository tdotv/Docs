variable "username" {
  type    = string
  default = ""
}

variable "password" {
  type    = string
  default = ""
}

# vcsa
variable "vsphere_server" {
  type    = string
  default = ""
}

variable "vsphere_dc" {
  type    = string
  default = ""
}

variable "vsphere_datastore" {
  type    = string
  default = ""
}

variable "vsphere_compute_cluster" {
  type    = string
  default = ""
}

variable "vsphere_network" {
  type    = string
  default = ""
}

# variable "vm_name" {
#   type    = string
#   default = ""
# }

variable "vsphere_template" {
  type    = string
  default = "ubuntu24-base-template-small"
}

variable "vm_domain" {
  type    = string
  default = ""
}

variable "vm_cpu" {
  type    = number
  default = 2
}

variable "vm_ram" {
  type    = number
  default = 2048
}

variable "multi_vm_name" {
  type = list(string)
  default = [
    "tf_multi_01",
    "tf_multi_02",
    "tf_multi_03"
  ]
}
