## What are the inbuild methods of few data types
- There are few supported data types in terraform
- To perform certain actions on few of these data types
- There are few default methods or functions available

## To know more about the functions
- https://developer.hashicorp.com/terraform/language/functions/join

## Lets make some data to perform certain actions on them
```
locals {
  value = "Hello world"
}
variable "string_list" {
    type = list(string)
    default = [ "server-1", "server-2", "server-3"] 
}
```
# working with string data type
# 1. Making the output in lower case 
# 2. Check if the string data is starting with certain string (its case sentitive)
```
output "value" {
    value = lower(local.value)
}
```
