variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "rgName" {
  default = "tfRG"
  description = "resource group created by Terraform"
}

variable "location" {
  default = "westus"
  description = "West US" 
}

variable "nsgName" {
  default = "nsg1"
  description = "West US" 
}

variable "vnetName" {
  default = "vnet1"
  description = "vnet1"   
}

variable "subnetName" {
  default = "subnet1"
  description = "subnet1"   
}

variable "admin_username" {
  type = string
  default = "huyen"
}

variable "admin_password" {
  type = string
  default = "123Cisco123!"  
}

variable "vmName" {
  type = string
  default = "epg1-01"
}