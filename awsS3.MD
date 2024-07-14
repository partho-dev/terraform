
## Common resources used for AWS S3
1. `aws_s3_bucket` - To create a bucket
2. `aws_s3_bucket_public_access_block` - Enable or Disable the public access to Bucket
3. `aws_s3_object` - To put object on bucket
4. `ws_s3_bucket_policy` - To enable JSON encoded policy on a bucket
5. `aws_s3_bucket_website_configuration` - To configure a bucket to host static website
6.  

## Random Provider
- for bucket unique name, we would need a random provider

```
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.58.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.2"
    }
  }
}
```

## Create a unique bucket name
```
resource "random_id" "rand_id" {
  byte_length = 8
}

# output "random_id_name" {
#   value = random_id.rand_id.b64_url
# }

resource "aws_s3_bucket" "s3-bucket" {
  bucket = "partho${random_id.rand_id.hex}"
    tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
```

## To have a public access enabled on a bucket
```
resource "aws_s3_bucket_public_access_block" "s3-public-block" {
  bucket = aws_s3_bucket.s3-bucket.id
  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets =false
  }
  ```

  ## To upload any object on a bucket
- Need `source` and `key` 
  ```
    resource "aws_s3_object" "static-website" {
    bucket = aws_s3_bucket.s3-bucket.bucket
    source = "./index.html"
    key = "index.html"
  }
  ```
  - for static website, need to add another argument
  `content_type="text/html`
  ```
  key = "index.html"
    content_type = "text/html"
    ```

  ## Apply policy on bucket
  - Just remove the `""` `:` from the key and add `=`
  - Get the policy from aws documentation

  ```
  resource "aws_s3_bucket_policy" "s3-policy" {
    bucket = aws_s3_bucket.s3-bucket.bucket
    policy = jsonencode(
    {
        Version = "2012-10-17",
        Statement = [
            {
                Sid   ="PublicReadGetObject"
                Effect = "Allow",
                Principal = "*",
                Action = "s3:GetObject",
                Resource = "arn:aws:s3:::${aws_s3_bucket.s3-bucket.bucket}/*"
            }]}
    )
    }

    ```

## Get a bucket configured to host website
- This enables the bucket for website  

```
resource "aws_s3_bucket_website_configuration" "my-static-website" {
  bucket = aws_s3_bucket.s3-bucket.id

  index_document {
    suffix = "index.html"
  }
}
```
## A Static website is hosted on S3 using terraform

<img width="623" alt="s3-static-web01" src="https://github.com/user-attachments/assets/b2b7504f-e660-45ce-862f-34b1094a1b36">

<img width="948" alt="s3-static-web02" src="https://github.com/user-attachments/assets/b0b3c14c-6a20-4e52-a19c-2f18360ab010">