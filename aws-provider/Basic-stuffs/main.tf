variable "basic" {
    type = list(string)
    default = [ "hello", "world", "" ]
}

locals {
  tup = [for item in var.basic : upper(item) if item != "" ]
  obj = {for item in var.basic : "${item}-name" => upper(item) if length(item)>0 }
}

output "tup_out" {
    value = local.tup
}
output "obj_out" {
    value = local.obj
}