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
### When not to use terraform workspace
- If the credentials are different for target environment [ if there are 2 different aws accounts, workspace would not be helpful]

