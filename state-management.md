## Terraform State

- It keeps track of the infrastructure that Terraform manages. 
- This state is stored in a file named `terraform.tfstate`, 
- this `tfstate` file maintains the info about all the resources tf creates, updates or deletes. 
- This maintains the state of current infra & desired infra

## When tf state file is created
- When we run `terraform apply` this file `terraform.tfstate` gets created
- This state file maintains the info of resources that it just created 
<img width="496" alt="tf-state" src="https://github.com/user-attachments/assets/217bb26c-85de-4de6-b07d-846cb22ab4c8">

## Why this file is so important 
- It tracks the resource that needs to be created or deleted
- It helps improve the performance by maintaining a local cache of resources state
- If we maintain this file in a common remote storage(s3), other team members can collaborate
- It helps to identofy the dependancies among the resources like ec2 creation has dependancies on vpc id

## How to maintain this state file 
- Remote State Storage: Store the state file in a remote backend such as AWS S3, Terraform Cloud, Azure Storage, or Google Cloud Storage. This facilitates collaboration and provides a single source of truth.
```
terraform {
  backend "s3" {
    bucket = "partho-state-bkt"
    key    = "partho_backup.tfstate"
    region = "ap-south-1"
  }
}
```
- once the backend block is ready, if we do `terraform apply`
    - in the s3 a bucjet is created `partho-state-bkt`
    - the file is also created `partho_backup.tfstate`
    - all the state gets updated to that file
    - From the local laptop, the file `terraform.tfstate` gets automatically deleted 
    - now the state gets managed on the remote location

- State Locking: Ensure the state is locked when changes are being applied to prevent simultaneous updates, which can cause inconsistencies. Most remote backends support state locking.
- State Encryption: Encrypt the state file both at rest and in transit to protect sensitive information contained in the state file.
- State Versioning: Enable versioning on the storage backend to maintain a history of state files, allowing you to roll back to a previous state if needed.

## State management commnds
1. `terraform state list` - List all resources
2. `terraform state show <resources>` - Shows a detailed info about some resource like aws_instance etc
3. `terraform state rm <resource>` - removes certain resource
4. `terraform state pull` -- To pull the state file


## Terraform state locking

![tf-state-lock](https://github.com/user-attachments/assets/59fdaaa5-fd4b-4dd7-b949-435280bfaf07)
- To store the state of terraform state file, we use remote storage like S3
- but, to minatin and avoid any conflict by allowing any concurrent state update to that state file by two different developer
- While the state file update is happening, we should ensure to lock it so that at the same time it can not be used to do further change
- To prevent this conflict and potential possibility of state file corruptions, we can use a DB to enable `state lock`

### main.tf 
- This is a remote tf state block, which all developer has to put on their main.tf to ensure it points to the correct remote state file
```
terraform {
  backend "s3" {
    bucket         = "partho-state-bkt"
    key            = "partho_backup.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "db-locks-table"  
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```
1. Create an S3 bucket named `partho-state-bkt`
2. create a dynamoDB with table name `db-locks-table`
3. keeo the Partition Key as `LockID` `string` and click on "create table"
<img width="883" alt="db-01" src="https://github.com/user-attachments/assets/17f5e375-8b78-4b34-9539-042e1c7d75ff">

4. Now once 1st developer executes terraform apply on his laptop, it would create a remote state file and it would update the LockID on Dynamoc
    - same time if another developer wants to update his code using terraform plan/apply, he would receive an error message `Error acquiring the state lock`
    - This is how the `LockID` gets created on DB and it locks the state file
<img width="1630" alt="db-02" src="https://github.com/user-attachments/assets/337447aa-2a4d-4216-b784-5a1f98d7195e">

