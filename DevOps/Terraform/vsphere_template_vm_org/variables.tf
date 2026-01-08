variable "username" {
  type    = string
  default = ""
}

variable "password" {
  type    = string
  default = ""
}

variable "vsphere_server" {
  type    = string
  default = ""
}

variable "vsphere_dc" {
  type    = string
  default = ""
}

variable "vsphere_datastore" {
  # HV2-datastore1
  # HV2-datastore2
  # Storage_5.46
  # Storage_7.28 
  type    = string
  default = ""
}

variable "vsphere_compute_cluster" {
  type    = string
  default = ""
}

variable "vsphere_network" {
  # VL105
  # VL102
  type    = string
  default = ""
}

variable "vm_name" {
  type    = string
  default = ""
}

variable "vsphere_template" {
  type    = string
  default = "ubuntu24-base-template-small"
}

variable "vm_domain" {
  type    = string
  default = ""
}
