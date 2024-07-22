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