~Disclaimer~ : Few of the examples here are AI generated . But, the concepts needed to be mastered
## How to ensure the terraform data is validated and showing the correct error message

- To validate variables in Terraform and ensure that they meet specific criteria, 
- We can use custom `validation` rules in the `variables.tf` file. 
- This allows to prevent errors and show descriptive error messages during terraform `plan` or terraform `apply`.

### What are the most Common Validations used in Terraform 

- ✅ `String Length`: Ensuring a string meets length requirements.
- ✅ `Number Range`: Validating numbers fall within a specific range.
- ✅ `Allowed Values`: Ensuring the value is within a predefined set of allowed values.
- ✅ `Regular Expressions`: Validating format and patterns using regex.

### Example: Validating a Subnet CIDR

- Let's say we have a variable for a subnet CIDR that should be within the range `10.0.0.0/24`. 
- We can add a validation rule to ensure that the entered value meets this requirement.

1. variables.tf
```
variable "subnet_CIDR" {
  description = "The CIDR block for the subnet"
  type        = string

  validation {
    condition     = can(regex("^10\\.0\\.0\\.[0-9]{1,3}/24$", var.subnet_CIDR))
    error_message = "The subnet_CIDR must be in the format 10.0.0.X/24 where X is between 0 and 255."
  }

  default = "10.0.0.0/24"
}
```


2. Validate the `string length`
```
variable "instance_name" {
  description = "Name of the instance"
  type        = string

  validation {
    condition     = length(var.instance_name) > 3 && length(var.instance_name) < 20
    error_message = "The instance name must be between 4 and 19 characters."
  }
}
```

3. Validating the `Number Range`

```
variable "instance_count" {
  description = "Number of instances to create"
  type        = number

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "The instance count must be between 1 and 10."
  }

  default = 1
}
```

4. Validation for `allowed values`

```
variable "environment" {
  description = "The environment for deployment"
  type        = string

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "The environment must be one of 'development', 'staging', or 'production'."
  }

  default = "development"
}
```

### Some advanced validations using `alltrue()` and `can()`
- to ensure multiple attributes meet specific criteria
5. Ensuring All Subnets Have Valid CIDR Blocks
```
variable "subnet_config" {
  # sub1 = {cidr_block=...} sub2={cidr_block=...} 
  type = map(object({
    cidr_block = string
    az         = string
    public     = optional(bool, false)
  }))
  
  validation {
    condition = alltrue([for config in var.subnet_config : can(cidrnetmask(config.cidr_block))])
    error_message = "Invalid CIDR format in one or more subnet configurations."
  }
}
```

6. Ensuring AZs are Valid
```
variable "subnet_config" {
  description = "Configuration for subnets"
  type = map(object({
    cidr_block = string
    az         = string
    public     = optional(bool, false)
  }))

  validation {
    condition = alltrue([for key, config in var.subnet_config : contains(["us-west-1a", "us-west-1b", "us-west-1c"], config.az)])
    error_message = "Invalid AZ in one or more subnet configurations."
  }
}
```

## Resource specific validations
- This is used during the resource lifecycle
- Terraform provide a way to enforce policies and checks before and after the application of infrastructure changes. 
- These validations can ensure that the infrastructure adheres to specific rules and requirements

### Two types of resource specific validations are there
- These two conditions can be used inside the lifecycle block of a resource

1. `pre-validation`
- It validates the conditions before a resource is created or modified.

- Examples:
  - ✅ Ensuring a required tag is present.
  - ✅ Validating naming conventions.
  - ✅ Checking that certain dependencies are met.

2. `post-validation`
- It validates condition after a resource has been created or modified.
- Examples:
  - ✅ Verifying that an instance is in a running state.
  - ✅ Ensuring that certain outputs meet predefined criteria.

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
    # ignore_changes = [ tags["Name"] ]

    precondition {
      condition     = length(aws_instance.webserver.tags["Name"]) > 0
      error_message = "The instance name must not be blank"
    }

    postcondition {
      condition     = self.tags["Name"] != ""
      error_message = "The instance name should not be blank"
    }

  }
}

```

### Enforcing policy as a code
- We can use Policy-as-Code Tools (e.g., Sentinel, OPA)
- Sentinel & OPA are very much used with Terraform cloud & terraform enterprise. 
- But, they can be setup locally as well 

1. Policy using `Sentinel`

- Sentinel allows to define policies that can enforce rules at various stages of the Terraform workflow.
- Ex: Instance type should be only t2.small, so if anyone writes tf code with other instance type, the policy would block that resource creation

- Example Sentinel Policy: ( AI Generated code )
```
import "tfplan/v2" as tfplan

main = rule {
  all tfplan.resources.aws_instance as _, instances {
    all instances as _, instance {
      instance.applied.tags contains "Environment"
    }
  }
}
```

2. Open Policy Agent (OPA)
- OPA can be integrated with Terraform to enforce policies
- Example of OPA policy

```
package terraform

deny[msg] {
  input.resource_type == "aws_instance"
  not input.config.tags["Environment"]
  msg = "Environment tag is required on all instances"
}
```

## Terraform Linter
- `ftlint`
- https://github.com/terraform-linters/tflint

- `Features`
  - TFLint is a framework and each feature is provided by plugins, the key features are as follows:
  - Find possible errors (like invalid instance types) for Major Cloud providers (AWS/Azure/GCP).
  - Warn about deprecated syntax, unused declarations.
  - Enforce best practices, naming conventions.

### Why do we need tflint
- When we create a resource with some incorrect configuration
- terraform `validate` or terraform `plan` does not have the capability to catch that
- Example 
```
resource "aws_instance" "name" {
  instance_type = "t2.microoo"
  ami = "ami-0ad21ae1d0696ad58"
}
```

- In the above, we know that the instance type is incorrect `t2.microoo`
- if we do `terraform validate` or `terraform plan` 
- This issue can not be observed

- <img width="481" alt="tflint" src="https://github.com/user-attachments/assets/4bde99bc-deb2-490c-8e2f-56326e7e1b72">

- But, `tflint` can easily detect that

- Lets see that below

### `Installation` of tflint

- Bash script (Linux):
```
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
```

- `Homebrew (macOS):`
```
brew install tflint
```

- Chocolatey (Windows):
```
choco install tflint
```
### Now, configure the `tflint`
- create a file on the working directory `.tflint.hcl`
- for AWS as target cloud - https://github.com/terraform-linters/tflint-ruleset-aws
- Enable the AWS cloud plugin
```
// .tflint.hcl

plugin "aws" {
    enabled = true
    version = "0.32.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
```
- The above code will enable tflint for AWS 

- initialise the `tflint`
```
tflint --init
```

- Now to validate any error on the code
```
tflint
```

- <img width="667" alt="tflint-2" src="https://github.com/user-attachments/assets/75993cba-ffa6-4b4b-8021-4bba188f9e66">

