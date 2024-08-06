## Import the resources from target cloud into Terraform
- resources are manually created on AWS
- We need a mechanism to get all the resources and put them on Terrafor, so that it can be tracked
- Manage the entire infra as a infra as code

## Why Import Resources?

- ✅ `Consistency`: Ensure all resources are managed uniformly through Terraform.
- ✅ `Documentation`: Maintain a clear, version-controlled representation of your infrastructure.
- ✅ `Automation`: Leverage Terraform's automation capabilities for existing resources.
- ✅ `Drift Detection`: Detect and correct configuration drift between your Terraform code and actual resources.

## In the existing cloud
- There is an Ec2 instance which was created manually
- That instance needs to be imported into 