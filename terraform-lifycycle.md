## What is Terraform lifecycle and why dp we need thta?

- 🔥 A production website is running on an Ec2 server, so we need some way to prevent destroy this resource using `terraform destroy`
- ✅ By default, if we use `terraform destroy` the terraform destroys the resources and changes its state
- ✅ This is one of the Terraform lifecycle prevention

- Terraform lifecycle settings allows to customize the lifecycle management of resources. 

- These settings are used to control how Terraform handles the creation, update, and deletion of resources. 

- Lifecycle settings are defined within a resource block in the Terraform configuration. `resource { lifecycle {} }`

### Why Use Terraform Lifecycle?

- Terraform lifecycle settings are used to:

   - ✅ Prevent Accidental Changes: Protect resources from being modified or deleted unintentionally.
   - ✅ Control Update Behavior: Specify how Terraform should handle updates to resources.
   - ✅ Manage Resource Dependencies: Ensure resources are created or destroyed in a specific order.

### Lifecycle Meta-Arguments

- Terraform provides several lifecycle meta-arguments:

    - ❶ `create_before_destroy`
    - ❷ `prevent_destroy`
    - ❸ `ignore_changes`
    - ❹ `replace_triggered_by`

### Practical examples

1. `create_before_destroy`

- It ensures that a new resource is created before the existing one is destroyed. 
- This is useful for resources where a downtime is unacceptable.
- Ex: A new Webserver should be created before destroying the current one
```
resource "aws_instance" "webserver" {
  ami           = "ami-0ad21ae1d0696ad58"
  instance_type = "t2.micro"
  tags = {
    Name = "tf-example"
  }

  lifecycle {
    create_before_destroy = true
  }
}
```

2. `prevent_destroy`

- Prevents the resource from being destroyed. 
- This is useful for critical resources that should not be accidentally deleted. (DB server)

```
resource "aws_instance" "webserver" {
  ami           = "ami-0ad21ae1d0696ad58"
  instance_type = "t2.micro"
  tags = {
    Name = "tf-example"
  }

  lifecycle {
    # create_before_destroy = true
    prevent_destroy = true
  }
}
```

3. ignore_changes

- Ignores changes to specified attributes. 
- This is useful for attributes that are managed outside of Terraform or that change frequently and don't require updates.
- Example - When we create an IAM user with a password of 10 chrecter long
- Then suddenly changing to 8, we can use this lifecycle to prevent change of the existing password
```
resource "aws_instance" "webserver" {
  ami           = "ami-0ad21ae1d0696ad58"
  instance_type = "t2.micro"
  tags = {
    Name = "tf-example"
  }

  lifecycle {
    # create_before_destroy = true
    # prevent_destroy = true
    ignore_changes = [ tags["Name"] ]
  }
}
```

4. replace_triggered_by
- Triggers a replacement of the resource when the value of the specified attribute or variable changes. 
- This is useful for forcing a recreation of resources based on changes in other resources or variables.

- example : Consider a scenario with AWS EC2 instance and an S3 bucket. 
- Ensure that the S3 bucket is not destroyed accidentally, and 
- the EC2 instance to be replaced if a new AMI ID is provided.

```
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-example-bucket"
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_instance" "example_instance" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [var.ami_id]
  }
}
```