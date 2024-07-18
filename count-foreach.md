## To create multiple resources
- count & foreach are used

## Task -1 : Create two subnets using count
- subnet-1 (10.0.0.0/24)
- subnet-2 (10.0.1.0/24)

## Remember
- count has these property 
- count.index

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