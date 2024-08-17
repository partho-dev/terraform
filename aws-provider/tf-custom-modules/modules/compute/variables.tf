variable "pub_sub_id" {
  description = "subnet-id from network module"
  type = string
}

variable "instance_name" {
    description = "name of the server"
    type = string
    default = "web-server"
  
}