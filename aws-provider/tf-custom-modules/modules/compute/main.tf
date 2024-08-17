resource "aws_instance" "main" {
    ami = "ami-0ad21ae1d0696ad58"
    instance_type = "t2.micro"

    subnet_id = var.pub_sub_id

    tags = {
      Name = var.instance_name
    }
  
}