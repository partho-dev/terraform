## To create multiple resources
- `count` & `foreach` are used
- both are called `Meta Arguments` of Terraform
- both count and for-each are used for same purpose of creating dynamic resources
- Differences
  - `count` works with `number` data type 
  - `for-each` works with `collections` of data through `map`, `list`, `set`

## Task -1 : Create two subnets using count
- subnet-1 (10.0.0.0/24)
- subnet-2 (10.0.1.0/24)

## Remember
- count has these properties
- count &
- count.index [starts from 0]

### Creating two subnets manually
1. Create VPC
```
# Create vpc
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
}
```

## Create two subnets manually
2. Create the 1st Subnet
```
resource "aws_subnet" "sub-1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
```
3. Create the 2nd subnet
```
resource "aws_subnet" "sub-2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}
```

## How to create two subnets using one resource
- use `count`
- use `count.index`

1. Create one local variable to get two names for subnet
```
# Create 2 subnets using count
resource "aws_subnet" "new-sub" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.${count.index}.0/24" // Two subnets
    count = 2
    tags = {
      name = "subnet-${count.index}"
    }
}
```
<img width="675" alt="tf-var-10" src="https://github.com/user-attachments/assets/6abbdb9d-c5dc-407b-9532-71f3decc0f55">

- Here, we have two subnets inside `new-sub`
- So, if we want to get the out put of subnets, we have to get it from the list of `new-sub`
<img width="866" alt="tf-var-11" src="https://github.com/user-attachments/assets/2ffa4675-2a60-43be-94ff-f3daebdc950d">

- So, as we are getting a list of arrays `[{}, {}]`
- we would need to use indexes `[0].key`
- example - we need value of subnet id for the first subnet
- `value = aws_subnet.new-sub[0].id`


## Task 2 : Create 4 Ec2 instances 2 in each subnets
- We need to retrieve single element from a list
- for that we have to use `element()` 
```
# Create Ec2 instances
resource "aws_instance" "name" {
  ami = local.ami
  instance_type = "t3.micro"
  count = 4
  subnet_id = element(aws_subnet.new-sub[*].id, count.index % 2)
    tags = {
    Name = "${local.project}-${count.index+1}"
  }
}
```
- `element(aws_subnet.new-sub[*].id, count.index % 2)`
- here `[*]` is the placeholder for index
- & the index is defined after `,` 
- manually typed index 
  - `[*], 0` which means `[0]`
  - `[*], 1` which means `[1]`
- but rather definfing the indexsed manually, we are using `count.index`
- `%2` is used to find odd or even index only 
- `%2 == 0` -- Only `even` number of index like `0, 2, 4 `
- `%2 != 0` -- only `odd` number of index like `1, 3, 5`
- `element(first_part, second part)`
- first part = It finds the single element(`id`) from all (`*`) list
- second part, which index (0 or 1) 0bjects needs to be shown

### Breaking down it to further to understand
`subnet_id = element(aws_subnet.new-sub[*].id, count.index % 2)`

```
#   subnet_id = element (aws_subnet.new-sub[*].id, 0) // 0th index
#   subnet_id = element (aws_subnet.new-sub[*].id, 1) // 1st index
It has count = 4
count.index = 0 % 2 = 0
1 % 2 = 1
2 % 2 = 0
3 % 2 = 1

- That means the subnet will be with in index 0 & 1
```

- But, the `% 2` is again a hard code
- to make it dynamic - `length(aws_subnet.new-sub)`
- `element(aws_subnet.new-sub[*].id, count.index % length(aws_subnet.new-sub))`

 ```
 # Create Ec2 instances
resource "aws_instance" "name" {
  ami = local.ami
  instance_type = "t3.micro"
  count = 4
#   subnet_id = element(aws_subnet.new-sub[*].id, count.index % 2)
subnet_id = element(aws_subnet.new-sub[*].id, count.index % length(aws_subnet.new-sub))
    tags = {
    Name = "${local.project}-${count.index+1}"
  }
}
```
4 Ec2 are created in 2 different subnets
<img width="1306" alt="tf-var-12" src="https://github.com/user-attachments/assets/6b670ca6-291f-4b81-9fc1-a2cd2408f24f">


## Task 3 : Create 2 subnets, first subnet should have 2 ec2 with ubuntu AMI, 2nd subnet has 2 Ec2 with amazon linux
```
# Create Ec2 instances
resource "aws_instance" "name" {
    count = length(var.ec2)
    ami = var.ec2[count.index].ami
    instance_type = var.ec2[count.index].instance_type

    subnet_id = element(aws_subnet.new-sub[*].id, count.index % length(aws_subnet.new-sub))
    tags = {
    Name = "${local.project}-${count.index+1}"
  }
}
```

## Terraform for_each (foreach) meta argument 
### Which data types are used for for_each
- The for_each meta-argument accepts a `map` or a `set of strings`
- **map**
- `map` is denoted as `key = value`
```
resource "azurerm_resource_group" "rg" {
  for_each = tomap({
    a_group       = "eastus"
    another_group = "westus2"
  })
  name     = each.key
  location = each.value
}
```
- Lets understand what is map and what is key = value

```
variable "ec2-instance" {
  type = map(object({
    ami           = string
    instance_type = string
  }))
  default = {
    "web-server" = { # Key
      ami           = "ami-12345678"  # Value (object with attributes)
      instance_type = "t2.micro"
    },
    "db-server" = {  # Key
      ami           = "ami-87654321"  # Value (object with attributes)
      instance_type = "t3.medium"
    }
  }
}
```
- Here , map is `map(object({ ... }))`
- Key: "web-server" and "db-server" in the default value are keys
- Value: The objects { ami = "ami-12345678", instance_type = "t2.micro" } and { ami = "ami-87654321", instance_type = "t3.medium" } are the values associated with each key.
- **Note**  : The map is key = value where value is anpther set of {key = value}
- map of object :  lets have an object {}
- Now object is key = value
- {key = value}
- here value is another set of object 
- `{key = {key=value}}`

- **Set of strings:**
```
resource "aws_iam_user" "the-accounts" {
  for_each = toset(["Todd", "James", "Alice", "Dottie"])
  name     = each.key
}
```

- for-each iterates over the map of objects and it iterates with default variable `each`
- if we want to know `key` - each.key
- if we want to know `value` - each.value [remember value is another object which has its own key = value format of data]
## How to work with for-each meta argument 

1. create the map of objects in variables.tf file with types
2. Define the map with proper data on terrafoem.tfvars file
3. create resource by calling the var on the main.tf file

### Create an Ec2 instance using for-each mata argument
1. create the map of objects in variables.tf file with types
```
variable "ec2-type" {
  type = map(object({
    ami = string
    instance_type = string 
  }))
}
```

2. Define the map with proper data on terrafoem.tfvars file
```
ec2-type = {
  // key = {key=value}
  "ubuntu" = {
    ami = "ami-0ec0e125bb6c6e8ec" 
  instance_type = "t2.small"
  }
  "amazon_linux" = {
    ami = "ami-0ad21ae1d0696ad58" 
  instance_type = "t2.small"
  }
}
```

3. create resource by calling the var on the main.tf file
- Few important items to know
-   `for_each = var.ec2-type`
- Here we will get `each.key` & `each.value` from the above for-each
- each.key will return "ubuntu" & "amazon_linux"
- each.value will return ami & instance type both with in another object {}
- To know the index position of each itarator, for count we used count.index, but for for-each to know the index position of each key, 
  - We need to use the inbuilt function `keys()` to know all the keys of map which we can do using each.key as well
  - to get the list of all keys use the inbuilt function keys(var.ec2-type)
  - but to know the postion of abobe all keys, we have another function called index() which wraps the keys() function
  - Know the index positions -  `index(keys(var.ec2-type))` 
```
## Creating ec2 using for-each meta argument
resource "aws_instance" "web-server" {
  # get the for-each called to create resource 
  for_each = var.ec2-type
  // Here we will get each.key & each.value from the above for-each
  ## each.key will return "ubuntu" & "amazon_linux"
  ## each.value will return ami & instance type both with in another object {}
  ami = each.value.ami
  instance_type = each.value.instance_type

  # subnet_id = element(aws_subnet.new-sub[*].id, index(keys(var.ec2-type), each.key) % length(aws_subnet.new-sub))
  subnet_id = element(aws_subnet.new-sub[*].id, index(keys(var.ec2-type), each.key) % length(aws_subnet.new-sub))
  tags = {
    Name = "${local.project}-instance-${each.key}"
  }
}
```
