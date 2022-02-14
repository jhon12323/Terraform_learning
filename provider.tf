provider "aws" {
  region     = "ap-south-1"
}

###### vpc block #######

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "first-vpc"
  }
}

######## igw block ############
resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "first-gw"
  }
}

####### subnet block ##########

resource "aws_subnet" "my_sub" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "first-subnet"
  }
}

######### route table ######

resource "aws_route_table" "my_route" {
  vpc_id = aws_vpc.my_vpc.id

  route = [] 
  tags = {
     Name = "first-route"
 }
}

resource "aws_route" "r" {
  route_table_id            = aws_route_table.my_route.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.my_gw.id
  depends_on                = [aws_route_table.my_route]
}

########### security group #########

resource "aws_security_group" "sg" {
  name        = "allow sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "All traffic"
    from_port        = 0
    to_port          = 0              #all ports
    protocol         = "-1"           #all traffic
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_traffic"
  }
}

###########route table association ##########

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_sub.id
  route_table_id = aws_route_table.my_route.id
}

###########ec2 instance #############

resource "aws_instance" "Ubuntu" {
  ami           = "ami-0851b76e8b1bce90b"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}
