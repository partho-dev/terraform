## How to handle tf credentials

1. if aws is the target cloud, we need an IAM user and its access key and secret access key
2. need to configure these creds on our local laptop, so the terraform reads that automatically and create resources on AWS using that user creds
3. `aws configure` for aws target clud
4. `az login` for azure target cloud

### For AWS
### 1st method  (not recommended)
- Hardcode the creds on main.tf file under provider block
```
provider "aws" {
  # Configuration options
  region = "ap-south-1"
  access_key = "aasss-fake"
  secret_key = "akjbkjbkjbkj-fake"
}
```

 ### 2nd method (Most recommended)
 - execute this command on mac terminal `aws configure `
 - enter all the keys
 - Terraform automatically reads from this location `/Users/macbook/.aws`

<!-- ## But, its good only for single user
-  so its good to store these creds in some certral secret location and these credentials should be generated dynamically & there should be some lifecycle management to rotate these creds
- for aws, there is a service called `AWS Secrets Manager` or `Hashicorp vault`
- It Easily rotate, manage, and retrieve secrets throughout their lifecycle -->

### 3rd method
- use environment variable
- export AWS_ACCESS_KEY_ID = "bkbkjnb-fake"
- export AWS_SECRET_ACCESS_KEY = "jhbkbkj-fake"