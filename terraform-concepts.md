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