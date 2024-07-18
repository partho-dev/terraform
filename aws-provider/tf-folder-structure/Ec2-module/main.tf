# main.tf of Ec2 module (Using the value from VPC module )


resource "aws_instance" "web" {
  ami = "ami-0ec0e125bb6c6e8ec"
  instance_type = "t2.micro"
   subnet_id = var.publicSubnet // This one we have to get from vpc module
   security_groups = [var.sg]
   tags = {
     Name = "Ec2-server"
   }
}

