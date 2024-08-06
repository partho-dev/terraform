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

