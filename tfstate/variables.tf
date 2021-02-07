variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "htduong01_aws_access_key" {}
variable "htduong01_aws_secret_key" {}
variable "htduong01_profile" {}

variable "aws_default_region" {
  type = string
  default = "ap-southeast-2"
  
}

variable "ubuntu_ami" {
  type = string
  default = "ami-041e1cc8f4c429789"
}

variable "server_port" {
  type = number
  default = 8080
}