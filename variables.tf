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

variable "myvar" {
  type = string
  default ="hello terraform"
}

variable "mymap" {
  type = map(string)
  default = {
    mykey = "my value"
  } 
}

variable "mylist" {
  type = list
  default = [1,2,3]
}