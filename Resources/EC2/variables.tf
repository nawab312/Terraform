variable "instance_type_var" {
    description = "Type of EC2 Instance to Use"
    type = string
    default = "t2.micro"  
}

variable "ami_id_var" {
    description = "AMI ID of EC2 Instance"
    type = string
    default = "ami-0e2c8caa4b6378d8c" #Ubuntu
}
