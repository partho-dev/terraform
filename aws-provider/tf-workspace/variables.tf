variable "ami" {
  description = "ami"
  type        = string
}

variable "instance_type" {
    description = "instance-type"
    type = map(string)
}