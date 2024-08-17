variable "vpc_cidr" {
    description = "CIDR of VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "vpc_Name" {
    description = "Name of VPC"
    type = string
    default = "new-test-vpc"
}

variable "public_subnet_cidr" {
    description = "CIDR of Subnet"
    type = string
    default = "10.0.1.0/24"
}