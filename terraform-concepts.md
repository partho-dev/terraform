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
    // publicSubnet = module.<module_name>.<output_name>
    publicSubnet = module.vpc-module.publicSubnet
    sg = module.vpc-module.sg
}

```

## Workspace in TF
- `workspace` is used mainly during the creation/manage of multiple distinct infrastructure configurations within same directory
- Dev, QA, Staging environment, prod etc can be managed using workspace in tf
### The problem, the tf workspace is solving
- Lets imagine, we have 2 different environments 
  - `dev` Environment
  - `QA` Environment
- Now, we have to create some resources(Ec2) in both the environment. 
- We will have one `main.tf` file where the resource block is defined.
- Rather hardcoding the resource properties like instance_type & ami on main.tf file
- we will use two different .tfvars file  (`dev.tfvars` & `qa.tfvars`)
- Define atwo different values of instance type on these two tfvars file 
- (`dev.tfvars - t2.small` & `qa.tfvars - t2.medium `)
- Now, if we apply the terraform to create resource in aws, it will override the resource with the new value.
- To apply the terraform with different tfvars, we can use the command `terraform apply -var-file="qa.tfvars"` & `terraform apply -var-file="dev.tfvars"`
- It will update the same Ec2 instance and change its instance type from t2.small to t2.medium.
- But, this is not what we wanted, we want to have two different Ec2 instances one with t2.small & other with t2.medium 
- For that, we would first need to create two different `new workspaces` and swith between the workspaces & execute tehe apply with respective tfvars file
- Commands
  - To see the list of workspaces - `terraform workspace list` [By default, there is only one workspace and it is **default*]
  - To create workspace - `terraform workspace new qa` [dont forget the keyword `new`] 
  - Everytime we create a workspace, it automatically switches the workspace to the newly created one
  - To select the appropreate workspace - `terraform workspace select dev`
  - To see the current selected workspace  - `terraform workspace show`
  - To delete the workspace - `terraform workspace delete qa`
- Remember - when we create workspace - it creates a new directory on the name of `terraform.tfstate.d` which maintains different environment tfstate files to isolate each resources 
- But, this folder would not be deleted if we delete the workspace. so need to delete that manually




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


## Is there a way we can find some similarities or pattern to remember things
1. Most of the Terraform constructs have similar pattern
- construct "construct-name" {key = value}
2. But, based on the constructs, the key changes

### Lets try to find some similarities among all
1. `module`
- module "module_name" {key = value}
- for module ==> key = source 
- `module "module_name" {source = "../"}`
*Remember* - to get some value from module, its module.module_name.output_name
- publicSubnet = module.<module_name>.<output_name>

2. `output`
- output "output_name" {key = value}
- for output == > key = value
- `output "output_name" {value = ..}`

3. `variables`
- variable "variable_name" {key = value}
- for variable == > key = description & type
- `variable "variable_name" {description = value type = string}`

4. `data source & resource`
- for data types & resources, the value of key changes based on the resources

5. locals does not follow the same patters
- It **does not** have the parameter *"local-name"*
- `local {key = value}`


## is map and object same or similar in Terraform
- Their blocks are similar {} and both holds the data in key = value format
- Only difference is
  - map expects all same types of data - map(string) or map(number)
  - object is also having key = value format, but it can be of different data types

## for loop with list, set and map
- remember the relation of `for` with `in` without any condition
- with condition, 3rd element also adds `for` `in` `if`

## for loop with list (list of strings & list of numbers)
### List & set of strings
```
variable "names" {
  type    = list(string)
  default = ["John", "Steve", "Jobs"]
}
```
- for with list of strings
- `for` & `in`
- `upper_case = [for name in var.names: upper(name)]`

### list of numbers
```
variable "numbers" {
  type    = list(number)
  default = [1, 2, 3, 4]
}
```
- for list of numbers
- `for` & `in`
- `double = [for num in var.numbers: num*2]`

### List of numbers with condition to return even number
- `for` `in` `if`
- `even_numbers = [for num in var.numbers: num if num % 2 = 0]`


## for loop with map
- `key`, `value` `=>`
### map is an object with similar data types
- here we are checking with map with string data types

```
variable "servers" {
  type = map(string)
  default = {
    server1 = "10.0.0.1"
    server2 = "10.0.0.2"
    server3 = "10.0.0.3"
  }
}
```
- Here, since its map, so the for loop will be inside {} for list its inside []
- `server_details = {for key, value in var.servers : key => "serverIP-${value}" }`
- This would be the output of the above for loop
```
server_descriptions = {
      + server1 = "serverIP-10.0.0.1"
      + server2 = "serverIP-10.0.0.2"
      + server3 = "serverIP-10.0.0.3"
    }
```

## for loop with set
- Its same as list `for` `in` 
*Note*
- both set(string) & list(string) has same structure as `["value1", "value2"]` within `[]`
- for value `["d", "a", "b", "c", "a"]`
- only difference 
  - set ( ` does not accept any duplicate value and should be in order`) - `["a", "b", "c", "d"]`
  - list ( ` accepts duplicate value in any order`) - `["d", "a", "b", "c", "a"]`

## for-each meta argument and its looping
- I have explained that very thoroughly on this - https://github.com/partho-dev/terraform/blob/main/count-foreach.md

## element function in terraform
- I have explined that very thoroughly on this - https://github.com/partho-dev/terraform/blob/main/count-foreach.md

## How to pass user data on Ec2 through Terraform
- create a file, `data.sh` and put all the commmands here
- on the Ec2 resource, use this key
- `user_data = file("data.sh")`

## To deploy EKS cluster on AWS
- These tags are needed to pass the traffic to respective cluster
- tags = {kubernetes.io/cluster/my-cluster = "shared"}
- For `public` subnet
  - public_subnet_tags = {kubernetes.io/role/elb = 1 kubernetes.io/cluster/my-cluster = "shared"}
- For `private` subnet
  - private_subnet_tags = {kubernetes.io/role/internal-elb = 1 kubernetes.io/cluster/my-cluster = "shared"}