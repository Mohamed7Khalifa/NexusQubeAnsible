#------------------VPC---------------------
resource "aws_vpc" "ansible_vpc" {
  cidr_block         = "10.0.0.0/16"
}

#------------------Public Subnets--------------------------
resource "aws_subnet" "public-az1" {
  vpc_id     = aws_vpc.ansible_vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "bastion host"
  }
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public-az2" {
  vpc_id     = aws_vpc.ansible_vpc.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "priv2"
   }
   availability_zone = "us-east-1b"
}

#------------------Private Subnets------------------------
resource "aws_subnet" "private-az1" {
  vpc_id     = aws_vpc.ansible_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "private-az1"
  }
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private-az2" {
  vpc_id     = aws_vpc.ansible_vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "bastion host"
  }
  availability_zone = "us-east-1b"
}


#-----------------------IGW & NGW-------------------------------------
resource "aws_internet_gateway" "ansible_igw" {
  vpc_id = aws_vpc.ansible_vpc.id
  tags = {
    Name = "ansible-igw"
  }
}

resource "aws_eip" "nat_ip" {

}

resource "aws_nat_gateway" "ansible_nat" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.public-az1.id
}

#-------------------------ROUTETABLES-----------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ansible_vpc.id
}

resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ansible_igw.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public-az1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public-az2.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.ansible_vpc.id
}

resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.ansible_nat.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private-az1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private-az2.id
  route_table_id = aws_route_table.private.id
}

#----------------------SG-------------------
resource "aws_security_group" "public_sg" {
  name        = "pub-sec-group"
  description = "Allow HTTP traffic from anywhere"
  vpc_id = aws_vpc.ansible_vpc.id
  tags = {
    Name = "public-ansible-sg"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
