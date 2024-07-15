## Workspace in TF
- `workspace` is used mainly during the creation/manage of multiple distinct infrastructure configurations within same directory
- Dev, QA, Staging environment, prod etc can be managed using workspace in tf

## Data types
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
So, to manage these data efficiently, terraform has its own datatypes and inbuilt methods to manupulate the data

![terraform-data-types](https://github.com/user-attachments/assets/7c96086e-2aef-4085-8105-a32dec4afeed)

### Basic Data types
* `string` 
```
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
```
* `number`
* `bool`

### Collection data types
* `list(string)`
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
