## Workspace in TF
- `workspace` is used mainly during the creation/manage of multiple distinct infrastructure configurations within same directory
- Dev, QA, Staging environment, prod etc can be managed using workspace in tf

## Terraform variables

- A variable is used to prevent repetation of hard coding the properties during resource creation
- Terraform has two types of variables
1. Input Variable
2. Output Variable
- When we write variable, it deals with different types of data & so, we would need to know more about `Data Types`

## Data types - Data types in Terraform
### Terraform List
For `JS` *Array* is kind of equivalent to `TF` *List*

- For `JS` 
```
let ec2-count = [1, 2, 3, 4]

```

- For `tf`
```
variable "ec2-count" {
  type = list(number)
  default = [ 1, 2, 3, 4 ]
}
```

### Terraform map
`JS` - *Object* kind of equivalent to `tf` - *map*

- For `js`
```
let ec2-server = {name:"web-server", ami:"abc-123"}
```

-for `tf`
```
variable "ec2-name" {
  type = map(object({
    name = string
    ami=string
  }))
default = {
  "server-1" = {
    name="webserver-1"
    ami="abc-123"
  }
}
}
```

## What are the data types in Terraform 
- Terraform deals with different types of data as an input to create infra
- ami 
- name of instance
- number of instances etc
- So, to manage these data efficiently, terraform has its own datatypes and inbuilt methods to manupulate the data

![terraform-data-types](https://github.com/user-attachments/assets/5688675e-14ea-4484-a628-11c363914f15)

### Basic Data types
* `string` 
```
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
```
* `number`
```
variable "instance_count" {
  type    = number
  default = 1
}
```
* `bool`
```
variable "enable_monitoring" {
  type    = bool
  default = true
}
```

### Collection data types
* `list(string)`
```
variable "availability_zones" {
  type    = list(string)
  default = ["us-west-1a", "us-west-1b"]
}
```
* `map(string)`
```
variable "tags" {
  type = map(string)
  default = {
    Name        = "example-instance"
    Environment = "production"
  }
}
```
* `set(string)`
```
variable "allowed_ips" {
  type    = set(string)
  default = ["192.168.1.1", "192.168.1.2"]
}
```

### Complex data types
* `object({})`
```
variable "person" {
  type = object({
    name = string
    age  = number
  })
  default = {
    name = "Alice"
    age  = 25
  }
}
```
* `tuple([string, number, bool])`

### Dynamic Types
* `any`


## What are the different string data types default methods for Terraform 👨‍💻
* String methods
1. `format()`
format("Hello %s!", "world") 
"Hello world!"
- Here, `%s` represents a placeholder for another string
- similarly `%d` for `integers` & `%f` for `floating numbers`

2. `formatlist()`
formatlist("Hello, %s", ["partho", "john"])
["Hello, partho", "Hello, john"]

3. `join()`
join(", ", [1,2,3])
"1, 2, 3"

4. `split()`
split(", ", "a", "b", "c")
["a", "b", "c"]

5. `lower()` - converts the string to lower case
6. `upper()` - converts the string to upper case
7. `replace()` 
8. `trimspace()`
9. `trimprefix()`
10. `trimsuffix()`
11. `substr()`
12. `indent()`
13. `regex()`
14. `length()` 

## Manage multiple resources using "count" & "for_each"
