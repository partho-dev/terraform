## Terraform variables

- A variable is used to prevent repetation of hard coding the properties during resource creation
- Terraform has two types of variables
1. Input Variable
2. Output Variable
- When we write variable, it deals with different types of data & so, we would need to know more about `Data Types`

## Terraform variables and their orders of preferences

            - environment var ( export TF_VAR_Key=value)
        - terraform.tfvars
    - *.auto.tfvars
- -var & -var-file (Through command line)

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

## Lets understand the use of variables and data types for building infrastructure
- 👍 Lets consider this resource block in our `main.tf` file

```
## main.tf

resource "aws_instance" "server" {
    ami = "ami-0ad21ae1d0696ad58"
    instance_type = "t2.micro"

    root_block_device {
      delete_on_termination = true
      volume_size = 30
      volume_type = "gp2"
    }

    tags = {
      name = "tf-server"
    }
}
```
- Here, we are using many static value for the infrastructure deployment
- This setup is fine for a single infrastructure, but its not recommended to hardcode the value on the code.
- We might use the same resource properties in many places, ex: `instance_type` and in the future if we happen to change the value from `t2.micro` to `t2.medium`, we would need to manually change the value on each place where its used.
- Instead of that, if we can maintain that as a variable and change the value of the variable, we would not need to manually update the value on all the places.
- This removed the human error and it saves the time.
- Lets make a seperate file and use the terraform `variable` for that 
- It has a syntax as variable `variable_name {//define the variable here}`

```
## variable.tf

variable "instance_type" {
  description = "mention the instance type here"
  default = "t2.micro"
}
```
- Now update the `main.tf` file with this variable
```
// main.tf

resource "aws_instance" "server" {
    ami = "ami-0ad21ae1d0696ad58"
    instance_type = var.instance_type // updated instance type using variable

    root_block_device {
      delete_on_termination = true
      volume_size = 30
      volume_type = "gp2"
    }

    tags = {
      name = "tf-server"
    }
}
```
<img width="751" alt="tf-var-01" src="https://github.com/user-attachments/assets/e4ef99d5-81dd-4345-92f9-9dc31031f7a9">

- If we dont put any value into the variable file, terraform would promot to input the value during `plan & apply`
```
## variable.tf
variable "instance_type" {
  description = "mention the instance type here"
}
```
- `Terraform plan`
<img width="662" alt="tf-var-02" src="https://github.com/user-attachments/assets/8060c837-563d-4098-8258-0ee8f7e5cd0d">
<img width="537" alt="tf-var-03" src="https://github.com/user-attachments/assets/9c3965ab-57d0-4107-a6ee-d377a96dd827">

- But, this leads to a potential issue of passing any value.
- To safeguard from this, we can define
    - the variable type ` string` or `number` or `object, list, etc`
    - We can provide some validations.

- Lets see them one by one
- Define the type as `string`
- provide a `validation` with `condition` and `error` 
<img width="848" alt="tf-var-04" src="https://github.com/user-attachments/assets/4f4e4a92-984b-49c3-b8b7-31b62effbfbd">

- If we dont want the users to input the value and provide a default value of instance type
```
variable.tf
variable "instance_type" {
  description = "mention the instance type here"
  type = string
  default = "t2.micro"
}
```

- The above resource has other hardcoded value as well like `volume_size = 30` & `volume_type = "gp2"` 
- since both are a part of same block on `root_block_device`, we can make two seperate variables of individual types or 
- make a single variable of single variable type `object(string)`

### Two seperate variables
```
variables.tf

variable "volume_size" {
    description = "enter the instance volume size"
    type = number
    default = "20"
}

variable "type" {
    description = "enter the instance volume size"
    type = string
    default = "gp2"
}
```
- On `main.tf` file
```
resource "aws_instance" "server" {
    ami = "ami-0ad21ae1d0696ad58"
    instance_type = var.instance_type

    root_block_device {
      delete_on_termination = true
      volume_size = var.volume_size
      volume_type = var.instance_type
    }

    tags = {
      name = "tf-server"
    }
}
```
- But, we can make these two seperate variables as a single variable 
- Since there are more than one properties, so we can wrap it inside the type `object`
`type=object({})`

```
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
```
- In the `main.tf`
```
resource "aws_instance" "server" {
    ami = "ami-0ad21ae1d0696ad58"
    instance_type = var.instance_type

    root_block_device {
      delete_on_termination = true
      volume_size = var.define-volume.volume_size // get from the variabl
      volume_type = var.define-volume.volume_type // get from the variabl
    }

    tags = {
      name = "tf-server"
    }
}
```
<img width="645" alt="tf-var-05" src="https://github.com/user-attachments/assets/ca760545-cdcf-43de-a8c0-36db33c5edb4">

## Lets understand, how the variables takes the precedence over the other
- This goes down with more precendence 
- Moves from top to bottom approach
    - variable file
    - environment var ( export TF_VAR_Key=value)
    - terraform.tfvars
    - *.auto.tfvars
    - -var & -var-file (Through command line)

- If the variable applies during `terraform apply` using ` -var` would overwrite all the other variables applied through the other means mentioned above.

### environment var ( export TF_VAR_Key=value) 
- It takes the precedence over the variable file
- make sure the variable name remains same on both variables.tf and the environment
<img width="731" alt="tf-var-06" src="https://github.com/user-attachments/assets/9af9b1b5-6874-4a6a-b908-15cc749c068e">
<img width="661" alt="tf-var-07" src="https://github.com/user-attachments/assets/092036a8-2686-4b27-b3c4-a787e8a0b176">

### terraform.tfvars
- It takes the precedence over the environment variable
- The value that we define on `terraform.tfvars` would overwrite the value passed on `variables.tf & environment`
- Create a file named `terraform.tfvars` [Thats the standard file name]
- copy all the variables name 
```
# terraform.tfvars

instance_type = "t2.small" ## In the variable file its t2.micro
define-volume = {
    volume_size = 30 ##In the variable file, it was 20
    volume_type = "gp2"
}
```
<img width="577" alt="tf-var-08" src="https://github.com/user-attachments/assets/53e2f40f-5a8f-4ecd-a7b8-ab68219d2d6b">

### *.auto.tfvars
- Sometimes, we need to keep all the variable value unchanged except certain values, in that case we use this file
- ex : `test.auto.tfvars`
- The value we put here takes over the value that is there on the `terraform.tfvars` file

### -var & -var-file (Through command line)
- The value that we pass through command like with `-var` while we apply the terraform, it takes `highest` precendece
`terraform plan -var 'instance_type="t2-large"'`


## Local variables
https://developer.hashicorp.com/terraform/language/values/locals
// Definition from official Terraform 
-  A `local` value assigns a name to an expression, 
- the name can be used multiple times within a module instead of repeating the expression.
    - `Input` variables are like `function arguments`.
    - `Output` values are like `function return values`.
### Declare Local variables
```
locals {
  service_name = "forum"
  owner        = "Community Team"
}
```
### Local variables assignment 
```
locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}
```

### Use of Local variables in the terraform resource
```
resource "aws_instance" "example" {
  # ...

  tags = local.common_tags
}
```

**Note** - 
- The local variable are serving the same purpose as `variables.tf` 
- It is differentiated by declaring it inside the `config` file
- the variable defined in `variables.tf` file are considered as global variable
- But, some situations, we need to use `local` variables as well

<img width="626" alt="tf-var-09" src="https://github.com/user-attachments/assets/3afd3df4-3b68-4b7b-8830-614083a287a7">



