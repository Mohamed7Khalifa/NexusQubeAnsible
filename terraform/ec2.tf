resource "aws_instance" "jump_host" {
 ami           = "ami-0557a15b87f6559cf"
 instance_type = "t3.xlarge"
 associate_public_ip_address = true
 subnet_id = aws_subnet.public-az2.id
 vpc_security_group_ids = [aws_security_group.public_sg.id]
 key_name = "ansible"

 tags = {
    Name = "jumphost"
  }

}


resource "aws_instance" "private-vm-az1" {
 ami           = "ami-0557a15b87f6559cf"
  instance_type = "t3.xlarge"
  associate_public_ip_address = false
  subnet_id = aws_subnet.private-az1.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name = "ansible"
  tags = {
    Name = "nexus-vm"
  }
}

resource "aws_instance" "private-vm-az2" {
 ami           = "ami-0557a15b87f6559cf"
  instance_type = "t3.xlarge"
  associate_public_ip_address = false
  subnet_id = aws_subnet.private-az2.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name = "ansible"
  tags = {
    Name = "sonarqube-vm"
  }
}
