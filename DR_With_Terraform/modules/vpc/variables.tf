variable "cidr_block" {
  description = "CIDR Block of VPC"
  type = string
}

variable "subnet_a_cidr" {
  description = "CIDR Block of Subnet A"
  type = string
}

variable "subnet_b_cidr" {
  description = "CIDR Block of Subnet B"
  type = string
}

variable "az_a" {
  description = "Availability Zone A"
  type        = string
}

variable "az_b" {
  description = "Availability Zone B"
  type        = string
}