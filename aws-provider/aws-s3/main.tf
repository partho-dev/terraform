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

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}


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

resource "aws_s3_bucket_public_access_block" "s3-public-block" {
  bucket = aws_s3_bucket.s3-bucket.id
  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets =false
  }

  resource "aws_s3_object" "static-website" {
    bucket = aws_s3_bucket.s3-bucket.bucket
    source = "./index.html"
    key = "index.html"
    content_type = "text/html"
    
  }

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

resource "aws_s3_bucket_website_configuration" "my-static-website" {
  bucket = aws_s3_bucket.s3-bucket.id

  index_document {
    suffix = "index.html"
  }
}

output "s3-bucket-output" {
    description = "This gives the name of the s3 bucket"
    value = aws_s3_bucket.s3-bucket.bucket
}

output "static-website-url" {
  value = aws_s3_bucket_website_configuration.my-static-website.website_endpoint
}
