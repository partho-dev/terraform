variable "instance_type" {
  description = "mention the instance type here"
  type = string
  default = "t2.micro"
}

variable "define-volume" {
    // object is key=value inside {}
   type = object({
     volume_size = number
     volume_type = string
   })
   default = {
     volume_size = 20
     volume_type = "gp2"
   }
}

