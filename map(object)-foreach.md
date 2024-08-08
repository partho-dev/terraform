## How can we create multiple resources of same kind
- Create two subnets for vpc_id = aws_vpc.main.id

### Important things to remember
- Both count & for-each actually loops through the object and place them inside a list []
- and inside list, the elements are considered with their index position
- Lets take this as example

- **Note** 👍 
- For simplicity, I am using `let` to define variable which is not allowed in Terraform, 
- For terraform, we have to use `locals {}` for that
**Example** 🥇 

`let listObj = ["partho", {public_subnet = {cidr = "10.0.1.0/24", az="ap-south-1a"}}]`
- here, `listObj[0]` = `"partho"`
- & `listObj[1]` = `{public_subnet = {cidr = "10.0.1.0/24", az="ap-south-1a"}}`
- & `listObj[1].public_subnet` = `{cidr = "10.0.1.0/24", az="ap-south-1a"}`
- & `listObj[1].public_subnet.cidr` = `"10.0.1.0/24"`
- & `listObj[1].public_subnet.az` = `"ap-south-1a"`
- Explanation
  - to find the value of element within a `list` ["a"] use index position inside `[0] `
  - to find the value of element within an `object` `{}`, use `dot .` and the object name, which is `key`


### Normal way of creation of subnets using Terraform Resource

**The problem in this approach**
- It needs to repeat the code multiple times 
- coding follows `DRY` - Dont Repeat Yourself

- Public Subnet 
```
resource "aws_subnet" "pub_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    tags = {
      Name = "public-subnet"
    }
}
```
- Private Subnet
```
resource "aws_subnet" "priv_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1b"
    tags = {
      Name = "private-subnet"
    }
}
```
- This creates the resource successfully in the provider cloud
- <img width="1503" alt="tf-subnets-manual" src="https://github.com/user-attachments/assets/235df22f-2a76-4125-bd05-1d961cfe82d1">

## How to make the same resource creation little more dynamic (use count & count.index)
- This approach gives a solution to follow `DRY`
- using `count` - we are able to reduce the effor of writing the resource twice
```
resource "aws_subnet" "subnet" {
    count = 2
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.${count.index+1}.0/24"
    availability_zone = "ap-south-1a"
    tags = {
      Name = "${count.index+1}-subnet"
    }
}
```
- But, this has a limtations of hardocing the count value to `2`
- The availability zone remains as `1a` for both the subnets
- Lets use variables and define the `Availabiliti zone`
- & then, make the count value as dynamic as the length of the Availabiliti zone
- Lets see how to achive that

### making the count value dynamic based on some variables value
- make a variable for availability_zones and make it a `list of strings`
- Now, the question here is - how to identify how to determine the variable type
- Simply, open the console and check the availability zones, it just has value within " ", no key
- So, its easily identified as string, since there are many strings of availability zones, we can put them in a list 

- Define az as a variable
```
variable "av_zones" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]

}
```
- Now use the count value based on the number of elements inside the List, 
- in the above example - the value is 2 as there are 2 elements inside the list ["ap-south-1a", "ap-south-1b"]

```
resource "aws_subnet" "subnets" {
  count             = length(var.av_zones) // the count value is defined by the azs value length
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = element(var.av_zones[*], count.index % length(var.av_zones))

  tags = {
    Name = "subnet-${count.index}"
  }
}
```
- From here, we are able to get two instances of subnets created based on two values of availability Zones.
- But, there are some limitations on the control, like the tag name or not able to define if the subnet is public or not.

### use for-each construct to get more control on the dynamic resource creation

### Have a subnet with one CIDR for public & private subnet each
- Here, since its only 1 CIDR for each subnets, so we will use map of strings

```
variable "av_zones" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]

}

variable "sub_cidrs" {
  type = map(string)
  default = {
    "public"  = "10.0.1.0/24"
    "private" = "10.0.2.0/24"
  }
}

resource "aws_subnet" "name" {
  for_each   = var.sub_cidrs
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value

  availability_zone       = element(var.av_zones[*], index(keys(var.sub_cidrs), each.key) % length(var.av_zones))
  map_public_ip_on_launch = each.key == "public"

  tags = {
    Name = "${each.key}-subnet"
  }
}
```

- This made things little controlled to create dynamic resources.
- But, if we want to create 2 public and 2 private, then for Subnet variable, we have to change the data type from 
- map of lists to map of objects

### For_each with  multiple values of CIDRs for subnets
- Define the variables
```
variable "sub_cidrs" {
  type = map(object({
    cidr      = list(string)
    is_public = bool
  }))

  default = {
    "public" = {
      cidr      = ["10.0.1.0/24", "10.0.3.0/24"]
      is_public = true
    }
    "private" = {
      cidr      = ["10.0.2.0/24", "10.0.4.0/24"]
      is_public = false
    }
  }
} 
```

- Here the data are map of objects 
- The data looks like this, pretty complex
- from single list of string 
    - `cidr = ["nn", "ccc"]`
    - to be converted into two seperate block pf objects 
    - `{cidr="nn"} {cidr="ccc"}`
```
{
       private = {
           cidr      = [
               "10.0.2.0/24",
               "10.0.4.0/24",
            ]
           is_public = false
        }
       public  = {
           cidr      = [
               "10.0.1.0/24",
               "10.0.3.0/24",
            ]
           is_public = true
        }
    }
```
- If you carefully structure this, it would look something like this
```
{ 
private = { cidr = ["10.0.2.0/24", "10.0.4.0/24" ] is_public = false }
public  = {cidr = ["10.0.1.0/24", "10.0.3.0/24" ] is_public = true}
}
```

- That means - there is a `outer block of map {}` which have `2` `key = value pairs`
- `1st pair` has key = `private` & value = `{ cidr = ["10.0.2.0/24", "10.0.4.0/24" ] is_public = false }`
- `2nd pair` has key = `public` & value = `{cidr = ["10.0.1.0/24", "10.0.3.0/24" ] is_public = true}`

- Further break down 
  - each pair`s value is another block of objects with its own properties
  - since value is an object, so to access the properties of that `object`, we have to use `object.property_name`
    - to know about `cidr` = `value.cidr`
    - but, again the cidr is a list, so to access the list element, we would need the index positions - `value.cidr[0]`
    
- Now, lets see how to deal with this data 
- We would need to convert that to a list of objects from map of objects
- Its easy to iterate over lists
- So, create a `locals` and run the loop over the map of objects to get a new output and save that to a different name
```
locals {
  subnet_configs = [for subnet_type, cidr_values in var.sub_cidrs : [for key, value in cidr_values.cidr: {
     cidr = value
     is_public = cidr_values.is_public
  } ] ]
}
```

- This changes the data like this
```
[
       [
           {
               cidr      = "10.0.2.0/24"
               is_public = false
            },
           {
               cidr      = "10.0.4.0/24"
               is_public = false
            },
        ],
       [
           {
               cidr      = "10.0.1.0/24"
               is_public = true
            },
           {
               cidr      = "10.0.3.0/24"
               is_public = true
            },
        ],
    ]
```

- This broke all inro an individual objects
- But, it made another nested List [List isnside another list]
- To make it a single list, we have to use `flatten()` function
```
locals {
  subnet_configs = flatten([for subnet_type, cidr_values in var.sub_cidrs : [for key, value in cidr_values.cidr: {
     cidr = value
     is_public = cidr_values.is_public
  } ] ])
}
```
- This flattens the two lists to a single list
- The output looks like this
- List of objects 

```
[
       {
           cidr      = "10.0.2.0/24"
           is_public = false
        },
       {
           cidr      = "10.0.4.0/24"
           is_public = false
        },
       {
           cidr      = "10.0.1.0/24"
           is_public = true
        },
       {
           cidr      = "10.0.3.0/24"
           is_public = true
        },
    ]
```
- Now its little easier to create subnets resource using this data

```
resource "aws_subnet" "name" {
    # for_each = local.subnet_configs // We cant use this directly because for each needs map of set, but its a tuple
    /*
    variable "example_tuple" {
    type    = tuple([string, number, bool])
    default = ["apple", 42, true]
    }
    we need to comvert the tuple to map or set
    locals {
    example_map = {
    for idx, val in var.example_tuple : idx => val
        }
    }
    */
    for_each = {for elem in local.subnet_configs: "${elem.cidr}" => elem }
    // here elem is the entire block of object  {cidr= "10.0.2.0/24" is_public = false}
    // To have a unique key, we would need to do the above to find the key 
    // 10.0.2.0/24 = {cidr= "10.0.2.0/24" is_public = false}
    // Now, its easy to 
    vpc_id = aws_vpc.main.id
    cidr_block = each.value.cidr
     availability_zone = element(var.av_zones[*], index(local.subnet_configs, each.value) % length(var.av_zones))
    map_public_ip_on_launch = each.value.is_public == true

    tags = {
      Name = each.key
    }
}
```

