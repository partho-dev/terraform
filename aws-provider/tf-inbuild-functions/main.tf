terraform {}

## Lets make some data to perform certain actions on them
locals {
  value = "Hello world"
}
variable "string_list" {
    type = list(string)
    default = [ "server-1", "server-2", "server-3"]
}

variable "number_list" {
    type = list(number)
    default = [ 1, 2, 3, 4, 5, 6 ,10, 12, 123, 224, 1, 12, 2 ]
  
}

# working with string data type
# 1. Making the output in lower case
# 2. Check if the string data is starting with certain string (its case sentitive)
# 3. split the value
# 4. find max or min from a list of numbers
# 5. find the absolute value of a given number (non zero number, any negative number gets positive number)
# 6. Find the length of a list
# 7. join the list into a string
# 8. check if some value presents in a list
# 9. remove duplicates from a list toset()
output "value" {
    # value = lower(local.value)
    # value = startswith(local.value, "h")
    # value = split(":", local.value) // converts string into a list
    # value = max(1,3,4,60) // min
    # value = abs(-15) // this will become +15
    # value = length(var.number_list) // 10
    # value = join(",", var.number_list) // convert list into a string 
    # value = contains(var.number_list, 10) 
    value = toset(var.number_list) // removes the duplicate from the list
}
