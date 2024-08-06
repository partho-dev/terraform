resource "aws_instance" "name" {
  ami           = var.ami
  instance_type = lookup(var.instance_type, terraform.workspace, "t2.medium")
}