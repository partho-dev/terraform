## terraform

- Terraform works in HCL language [ Hassicorp Configuration Language ]
- The most 4 important commands that will always be used in Terraform are to initialize the terraform 
    - terraform init
    - terraform plan
    - terraform apply
    - terraform destroy
* terraform state 
	- terraform state list
	- terraform state show {list}

### How the HCL language format looks like?

Resource    “aws_instance” “Any_Name”
block_type “block_type” “block_type” {}
```
Resource “aws_instance” “foo”{
ami = “ami_id”
instance_type = “t2_micro”}

```

## Create resources on AWS: 
    Create a VPC, 
    Create an Internet Gateway
    Create a subnet
    Create an EC2 with its SG
    Create Route Table to forward traffic in and out of the subnet

- Open visual studio
- Create the file provider.tf 
- **Note** : Dont put access/secret access key on this file
- To keep this secret, type aws configure & update the key there
- To make it more professional and maintain a file for different customer
- Use this command  “aws configure --profile customer_name_1”
	

## Steps to use Terraform
1. install that on your laptop from the official doc - https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

2. Create an AWS IAM user for programmatic access
AWS root user profile - right click - security credentials - create access & secret access key
3. configure your local laptop with the AWS account 
4. `aws sts get-caller-identity` if this outputs the value like `arn, urerID` that means, the configuration is set correctly
```
{
    "UserId": "AIDASAMPLEUSERID",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/DevAdmin"
}
```
5. Now, local laptop and aws account is logically connected to execute some actions
6. Write the terraform scripts as main.tf
7. Navigate to that folder where the project is setup with `main.tf` file 
8. cd /project/
9. `terraform init` --> This will initialise the terraform backend and it reads the provider info from main.tf file and continue to create commands specific to that provider (aws or azure or gcp)
10. then need to execute some commands to make the actions
    - terraform init
    - terraform plan
    - terraform apply
    - terraform destroy
11. terraform state file - After the terraform is applied, it creates a state file to keep a track of what resources it created so it can delete them again.

## How to connect to a provider
1. For AWS
- We would need to create an IAM user and give the user admin policy attached, so that it has full access on the aws to create, delete or update the aws resources.
- Now, configure the laptop with aws configure to create a profile
- Create a `pem` file using `aws cli` - `aws ec2 create-key-pair --key-name terraform-key --query 'KeyMaterial' --output text > terraform-key.pem`
- Its not safe to update the aws access key & secret access key from the main.tf file
- So, we would create one `.tfvar` file where we will keep all the secrets and we would use `gitignote` to prevent this file get into public
- file name `terraform.tfvars`
**Note** : These way of setting up the creds is not suggested
```
aws_access_key = ""
aws_secret_key = ""
ssh_key_name = "name_of_key"
private_key_path = "name_of_key.pem" // ensure the pem file is on the same path

```

Its best to create a `.env` file and `export` these credentials to be used - https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html
```
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=us-west-2
```
- But, ensure the aws is configured on the laptop, to verify that
Type this on the laptop
`cd ~/.aws && cat credentials`

<img width="250" alt="Terraform-01" src="https://github.com/partho-dev/terraform/assets/150241170/48f0cc5d-ed9e-48c7-ab48-bc631f7fc670">


- Once these `secrets` are set into `tfvars` or `.env` file, we can access them on our `main.tf` file
- once the `.env` file is updated, we need to set that on our shell `source .env`
    - Its a temporary, if we close the shell, we will lose and then we would need to set that again by typing `source .env` 
- We can use Terraform variables to store the values and use them where its needed

```
# VARIABLES
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "ssh_key_name" {}
variable "private_key_path" {}

variable "region" {
  default = "ap-south-1"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "subnet1_cidr" {
  default = "172.16.0.0/24"
}
```

### Lets see how to use these variables during resource creation inside main.tf file

```
# For PROVIDERS
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}
```

## Whats next once the hcl is written.
Once the scripts are written using `.tf` file.
1. initialise the terraform
- `terraform init`
- When we do `terraform init`, 
- It creates a hidden folder `.terraform` 
    - which includes `lock.json` & `terraform provider file`
- it initialises the backend and mainly, 
- it initialise the `provider`
    - finds the latest version of aws for hashicorp
    - installs the latest aws version for hashicorp
- Then it creates as `.terraform.lock.hcl` file

<img width="259" alt="Terraform-02" src="https://github.com/partho-dev/terraform/assets/150241170/bf76f635-0ba9-46fb-9a99-53afabccffb6">


2. Observe, what resource going to be created
- `terraform plan` 
- we can use the optional `-out=FILE` option to save the generated plan to a file on disk, which you can later execute by passing the file to terraform apply
    - `terraform plan -out=outfile.tfplan` // Its best practise to use `.tfplan` as an extension to that file
- When we create a plan, a dependancy graph is created, which we can see from the terminal with 
    - `terraform graph`
    - The output is a `diagraph` which can be visualised from this website - http://webgraphviz.com/
    - Just copy the diagraph from terminal and pase on the above web
    
    <img width="1174" alt="Terraform-03" src="https://github.com/partho-dev/terraform/assets/150241170/f7357ef1-7488-4542-98c6-35d27d763708">
    - the plan file`s content can not be visible on IDE, to view that we need to run the command
    - `terraform show ec2plan.tfplan` // This format is readable by human
    - To generate machine readable format, which is used during integration of Terraform with other tools during CI/CD or similar
        - `terraform show -json ec2plan.tfplan`
    <img width="1174" alt="Terraform-03" src="https://github.com/partho-dev/terraform/assets/150241170/642b859a-24d9-49b4-945b-5fb673d35020">

3. Once the plan is ready with or without any file, its ready now to be deployed and 
    - this creates the resources on the given provider
    - `terraform apply`
    - or `terraform apply ec2plan.tfplan`

## How to maintain the state 
- When we run `terraform apply` it creates a state file `.tfstate` which records the current state 
**Important** 🆘 
- This `state` file is very crucial and so, we have to store that safely on local or on remote

4. This creates an Ec2 resource on AWS, but on the terminal, it does not provide the Public IP of the instance.
<img width="841" alt="TF-01" src="https://github.com/partho-dev/terraform/assets/150241170/2206d2ea-c65b-4586-9aa6-a072bfc77b83">

## How to get the output as the IP of the instance
- For that we have to do the below
    - use terraform `outputs`
    - add the output block on `main.tf` or on a seperate file 
<img width="624" alt="tf-01" src="https://github.com/partho-dev/terraform/assets/150241170/1f50ece2-ff2f-4ec8-9879-125e7f765ab1">

## How to delete all the resources that are created using Terraform
5. Run `terraform destroy` command and it will delete all the resources which are created during `terraform plan`

## Why there was a need of seperate language like HCL where other existing language like yaml exist
- Terraform works on programming language principles
- It uses data types like `strings` `Number, Booleans`and other complex data types `List, set, map` etc
- It also loops the data 
- So, it needed that principle and hence it needed its own `HCL` language

## Is there a way, to check if the .tf file is correctly written
- `terraform validate`
- Try by typing some resource name incorrect like `instance_types = "t2.micro"` with an extra `s`
- This will warn with `validate`

## Few important points to note
1. `depends` is used when one resource creation should happen once the previous dependable resource is created
2. `count=4` is used to create 4 resources at a time
4. `terraform destroy -target` is used to delete only one target resource rather destroying the entire infra
5. `import` is used to create IaC from an existing infra created manually
6. `terraform validate` is used to validate if any error on the syntax
7. **Test**
    - `terraform-compliance` is used for unit testing the Terraform script
    - `Terratest` - integration test
    - `tfsec` - Static analysis
8. 