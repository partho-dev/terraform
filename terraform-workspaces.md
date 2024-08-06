## Workspace in TF
- `workspace` is used mainly during the creation/manage of multiple distinct infrastructure configurations within same directory
- Dev, QA, Staging environment, prod etc can be managed using workspace in tf

## The problem, the tf workspace is solving
- ✅ Creating two different environments
- ✅ Lets imagine, we have 2 different environments 
  - `dev` Environment
  - `QA` Environment

- ![tf-workspace](https://github.com/user-attachments/assets/f831f6ad-87bd-4418-aa94-8cda2d39f619)


### Create some resources(Ec2) in both the environment. `QA` & `Dev` 🥇

- We will have one `main.tf` file where the resource block is defined.

- Rather hardcoding the resource properties like instance_type & ami on main.tf file

- we will use two different .tfvars file  (`dev.tfvars` & `qa.tfvars`)
- Define two different values of instance type on these two `tfvars` file 
- (`dev.tfvars - t2.small` & `qa.tfvars - t2.medium `)
- Now, if we apply the terraform to create resource in aws, it will override the resource with the new value
- This happens, because we have `state` file which maintains the state of current infra and any new request is considered as a new state change request.
- So, by having two seperate `tfvars` with different resource properties would not solve the problem of creating two distinct enviornmeny
- To apply the terraform with different tfvars, we can use the command `terraform apply -var-file="qa.tfvars"` & `terraform apply -var-file="dev.tfvars"`

- It will update the same Ec2 instance and change its instance type from t2.small to t2.medium.

- But, this is not what we wanted, we want to have two different Ec2 instances one with t2.small & other with t2.medium 

## What is the solution? `Terraform workspace 🔥 `
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
### When not to use terraform workspace
- If the credentials are different for target environment [ if there are 2 different aws accounts, workspace would not be helpful]



## Demo 
1. Creating the normal way 
- Create one default terraform.tfvars with this variable
```
ami = "ami-0ad21ae1d0696ad58"
instance_type = "t2.micro"
```

- Now, apply the terraform
- `terraform apply --auto-approve -var-file="terraform.tfvars"`
- Lets see the instance_type once the resource is created
```
terraform show | grep "instance_type"                      
instance_type                        = "t2.micro"
```

- Now, create another tfvars file `qa.tfvars`
```
ami = "ami-0ad21ae1d0696ad58"
instance_type = "t2.small"
```
- apply the terraform with the new tfvar file
- `terraform apply --auto-approve -var-file="qa.tfvars"`
- Expectation is to have two instance 
  - one the previous one
  - 2nd the one that we are creating using the new qa.tfvars file

  ```
  terraform show | grep "instance_type"                  
  instance_type  = "t2.small"
  ```

  - Here, we can see the instance type got overwritten from micro to small
  - It did not help to create two seperate instances with two different instance type

  ## So, whats the solution
  ### Use Terraform Workspace

 - Before installing new workspace, the folder looks like this
```
    tree -a

    ├── .terraform.lock.hcl
    ├── dev.tfvars   [Not Suggested]
    ├── main.tf
    ├── providers.tf
    ├── qa.tfvars
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    ├── terraform.tfvars
    └── variables.tf
```
  - Create two new workspaces
  ```
  terraform workspace new dev
  terraform workspace new qa 

  terraform workspace list
    default
      dev
    * qa [ Here * means, this workspace is selected now]
  ```

- Now, see the folder
```
tree
.
├── dev.tfvars
├── main.tf
├── providers.tf
├── qa.tfvars
├── terraform.tfstate
├── terraform.tfstate.backup
├── terraform.tfstate.d [This folder gets auto created when we create workspace]
│   ├── dev
│   └── qa
├── terraform.tfvars
└── variables.tf

```

- Creating a resource from `qa` workspace and using `qa.tfvars` for variables
- `terraform apply --auto-approve -var-file="qa.tfvars"`

- switc to `dev` workspace and apply the terraform using default tfvars
- `terraform apply --auto-approve -var-file="terraform.tfvars"`

- On the dashboard, we can see now two different types of instances running without overwriting the other
- <img width="843" alt="tf-wos" src="https://github.com/user-attachments/assets/5ed5acc8-f7ff-418c-bdfd-4a381385513b">

```
tree
.
├── dev.tfvars
├── main.tf
├── providers.tf
├── qa.tfvars
├── terraform.tfstate
├── terraform.tfstate.backup
├── terraform.tfstate.d
│   ├── dev
│   │   └── terraform.tfstate [seperate tfstate file]
│   └── qa
│       └── terraform.tfstate [seperate tfstate file]
├── terraform.tfvars
└── variables.tf
```

- ❌ on the above, we are passing the instance_type as a variable seperately from all tfvars file
- ❌ instead, we can pass them as  list of strings variable

- Updating the variables.tf file
```
  variable "instance_type" {
    description = "instance-type" }
```
- updating the tfvars file
```
instance_type = {
  "qa" = "t2.micro"
  "dev" = "t2.small"
}
```

- using `lookup()` while calling the variables
- main.tf 
```
resource "aws_instance" "name" {
  ami           = var.ami
  instance_type = lookup(var.instance_type, terraform.workspace, "t2.medium")
}
```

- switch to `dev` workspace and the instance type should be `t2.small`

```
 instance_type                        = "t2.small"
```
