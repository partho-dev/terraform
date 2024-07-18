variable "ec2" {
  type = list(object({
    ami = string
    instance_type = string
  }))
}