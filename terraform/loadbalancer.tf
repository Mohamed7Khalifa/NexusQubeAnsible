resource "aws_lb" "ansible_lb" {
  name               = "ansible-lb"
  internal           = false
  ip_address_type = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = [aws_subnet.public-az1.id,aws_subnet.public-az2.id]
  tags = {
    Name = "ansible-lb"
  }
}

resource "aws_lb_target_group" "ansible_tg" {
  name     = "targetGroup1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ansible_vpc.id
  tags = {
    Name = "ansible_tg"
  }
}

resource "aws_lb_target_group_attachment" "attach-priv1" {
  target_group_arn = aws_lb_target_group.ansible_tg.arn
  target_id        = aws_instance.private-vm-az1.id
  port             = 8081
}

resource "aws_lb_target_group_attachment" "attach-priv2" {
  target_group_arn = aws_lb_target_group.ansible_tg.arn
  target_id        = aws_instance.private-vm-az2.id
  port             = 9000
}

resource "aws_lb_listener" "listener1" {
  load_balancer_arn = aws_lb.ansible_lb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ansible_tg.arn
  }
}
