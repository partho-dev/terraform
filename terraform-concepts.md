## What is the Terraform folder structure
<img width="539" alt="tf-folder-structure" src="https://github.com/user-attachments/assets/2862ef9d-56bd-4e86-bdd9-158ab9231f23">

## How to access a value from one child module to another
- Example : the `SG` & `vpc` info would be on `vpc module`
- But, to create an `ec2` we would need the `VPCID` & the `SG`, but they belong to otherc child module
- To accomplish that, we would need to know which module is `source` and which is `target`
- On the source module, Module where the value needs to come from, need to update the values in `output.tf` file
- On the target module, the module where the value is needed,  we would need to have blank `variables` which are needed
- Then on the parent `main.tf` we need to call both the child modules, so that these child modules can use their resources

- We need to get the value of `vpc id` & `sg` from - VPC module, so this is our source module.
- We will get all the value of it into its `output.tf` file
```
## output.tf of VPC module, getting the output of its main.tf 

output "vpc-id" {
  value = aws_vpc.test-tf-vpc.id
}

output "sg" {
  value = aws_security_group.securityGroup.id
}

output "publicSubnet" {
  value = aws_subnet.public-subnet.id
}
```
- Now, go to the module where the values are needed & create blank variables in `variable.tf` file
```
# variables.tf file on Ec2 module 

variable "sg" {
  
}

variable "publicSubnet" {
  
}
```
- now, on Ec2 module, go to its `main.tf` file and use these variables
```
# main.tf of Ec2 module (Using the value from VPC module )


resource "aws_instance" "web" {
  ami = "ami-0ec0e125bb6c6e8ec"
  instance_type = "t2.micro"
   subnet_id = var.sg // This one we have to get from vpc module
   security_groups = var.publicSubnet
   tags = {
     Name = "Ec2-server"
   }
}
```

- Now, go to parent `main.tf` file and call both the child modules
```
# Call both the child modules on parent main.tf file 

module "vpc-module" {
    source = "./vpc-module"
  
}

module "ec2-module" {
    source = "./Ec2-module"
    publicSubnet = module.vpc-module.publicSubnet
    sg = module.vpc-module.sg
}

```

## Workspace in TF
- `workspace` is used mainly during the creation/manage of multiple distinct infrastructure configurations within same directory
- Dev, QA, Staging environment, prod etc can be managed using workspace in tf

## Data block
- It is used to fetch read only data for the resource from the provider
```
data "aws_iam_access_keys" "example" {
  user = "an_example_user_name"
}

```

## output
- We dont have console.log() to see any output upon code execution, 
- this is usually done using `output` block on terraform

### How to fetch data from the provider

```
data "aws_ami" "ami" {
  //Still we dont know what is the value the data would provide
    most_recent      = true
    owners           = ["amazon"]
}

output "ami" {
// To know the output of the data block for ami
  value = data.aws_ami.ami.id
}
```
<img width="579" alt="data-01" src="https://github.com/user-attachments/assets/1984baf2-00c9-4318-91e0-dd5e84f9f9f5">

### How to fetch data from the existing account
1. There is a security group and we need to use that to launch an Ec2
- First need to get the security group id using `data`
- The easiest way is to fetch the SG through data block is using its `Tags` or its `id`

```
data "aws_security_group" "name" {
    id = "sg-4bdda035"
}

output "sg" {
    value = data.aws_security_group.name.name
  
}
```

## filter in Terraform
- To filter in terraform, we have to use `for` and `if`
```
locals {
  // double the list of numbers
  double_num = [ for elem in var.num_list : elem*2 ]

  # Odd number (filter)
  odd_num = [for num in var.num_list:num if num%2 !=0] // use of (for in if)
}
```

## To perform some operation on map
- If we want to return a new map with some calculations, we have to use this syntax
- Since, its a new map, so we will use object to map the values within {}
- key=>value
- Doubling the value in map
`double_value = {for key, value in var.instance_type: key=>values*2 }`

## If we have two subnets, but need to create 4 ec2, 2 in each
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

## What are the most common ways we get data into our Terraform 
1. `input variables`
```
variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}

```

2. Environment varaibles
```
export TF_VAR_instance_type="t2.medium"

```
3. command line - var
```
terraform apply -var="instance_type=t2.large"

```
4. terraform.tfvars
- It fills the data based on type that we set on variables.tf file
5. `Data sources ` - Used to retriev info from external source
```
data "aws_availability_zone" "name" {
    state = "available"
}
```
6. Local values
```
locals {
  instance_type = "t2.micro"
}

resource "aws_instance" "example" {
  instance_type = local.instance_type
}

```
7. outputs
```
output "instance_ip" {
  value = aws_instance.example.public_ip
}
```
8. External data sources - makes use of data from external program
```
data "external" "example" {
  program = ["python3", "${path.module}/external_script.py"]

  query = {
    key = "value"
  }
}

```
9. modules
```
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"
}
```