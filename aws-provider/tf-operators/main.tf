terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.58.0"
    }
  }
}
provider "aws" {
  # Configuration options
  region = "us-east-1"
}

## Dedicated to M Prashant Youtube to list them properly
# Number list
variable "num_list" {
    type = list(number) // list means [] -Array in JS 
// This will have numbers inside [default = [  ]
default = [ 1, 2, 4 ]
}


# Calculations
locals {
  add = 2+7
  mul = 2*4
  eq = 2 !=3 

}

locals {
  // double the list of numbers
  double_num = [ for elem in var.num_list : elem*2 ]

  # Odd number (filter)
  odd_num = [for num in var.num_list:num if num%2 !=0]
}

output "output" {
  value = var.num_list
}

output "double_num" {
    value = local.double_num
}


# Object list of objects [{} , {}]
# Key = Value () 
variable "list_person" {
    type = list(object({
      name = string
      age = number
    }))
    default = [ {
      name = "Partho"
      age = 40
    },
    {
      name = "John"
      age = 50
    } ] 
}

locals {
  # Get only the  name from the list of objects
  list_name = [for person in var.list_person:person.name ]
}
output "person" {
  value = local.list_name
}


# Map List
variable "instance_type" {
  type = map(number)
  default = {
    "t2-micro" = 10
    "t2-small" = 15
  }
}

locals {
  # find only the key in the map
  mapped_key = [for key, value in var.instance_type : key]

  # find another map with the value as double
  # Since, its a new map, so we will use object to map the values within {}
  double_value = {for key, value in var.instance_type: key=>values*2 }
}
output "key_map" {
  value = local.mapped_key
}