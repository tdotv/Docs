terraform {
  required_providers {
    vsphere = {
      source  = "local/vmware/vsphere"
      version = ">= 2.0.0"
    }
  }
}

provider "vsphere" {
  user                 = var.username
  password             = var.password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
  api_timeout          = 10
}
