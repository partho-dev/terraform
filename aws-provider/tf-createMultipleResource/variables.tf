variable "ec2" {
  type = list(object({
    ami = string
    instance_type = string
  }))
}

variable "ec2-type" {
  type = map(object({
    ami = string
    instance_type = string 
  }))
}