## What we need for VPC on AWS
1. VPC with CIDR - 10.0.0.0/16
2. One public subnet - 10.0.1.0/24
3. One Private subnet - 10.0.2.0/24
4. Internet Gateway to connect with Public Subnet
5. Public Route table for public subnet which takes all traffic to internet (`0.0.0.0/0`) through IG
6. Private Route Table which keeps the traffic within the VPC (10.0.0.0/16) 
