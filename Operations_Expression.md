## Dive into the use of real programming with Terraform

- We will see the real use of different data types

### Number List
```
variable "num_list" {
    type = list(number) // list means [] -Array in JS 
// This will have numbers inside default = [  ]
default = [ 1, 2, 4 ]
}
```
# Object list of objects [{} , {}]
# Key = Value () 
```
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
```

# Map List
```
variable "instance_type" {
  type = map(number)
  default = {
    "t2-micro" = 10
    "t2-small" = 15
  }
}
```

# Calculations
```
locals {
  add = 2+7
  mul = 2*4
  eq = 2 !=3 
}

output "output" {
  value = var.num_list
}
```

## Lets use for and for-each loops with the data
- Make the numbers inside the list double
```
variable "num_list" {
    type = list(number) // list means [] -Array in JS 
// This will have numbers inside default = [  ]
default = [ 1, 2, 4 ]
}
```
- We would need to `loop` through the list and perform the `action` 
**Syntax**
`[for num in var.num_list: num*2]`
### Loop through each number on the list []
```
locals {
  // double the list of numbers
  double_num = [ for elem in var.num_list : elem*2 ]
}
```

### See the output of the double number 
```
output "double_num" {
    value = local.double_num
}
```

### See the output with some condition filter
- use `for` and `if`
```
locals {
  // double the list of numbers
  double_num = [ for elem in var.num_list : elem*2 ]

  # Odd number (filter)
  odd_num = [for num in var.num_list:num if num%2 !=0]
}
```

### How to find only the key or value from a mapped data type

1. Data type
```
# Map List
variable "instance_type" {
  type = map(number)
  default = {
    "t2-micro" = 10
    "t2-small" = 15
  }
}
```

2. Finding the key from mapped data
```
locals {
  # find only the key in the map
  mapped_key = [for key, value in var.instance_type : key]
}
output "key_map" {
  value = local.mapped_key
}
```
3. To find the **value** ` mapped_key = [for key, value in var.instance_type : value]`

## How to return another map from an exiting map based on some calculations
- `key=>values*2`
```
locals {
  # find another map with the value as double
  # Since, its a new map, so we will use object to map the values within {}
  double_value = {for key, value in var.instance_type: key=>values*2 }
}
```
