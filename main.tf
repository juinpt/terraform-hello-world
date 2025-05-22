provider aws {
  profile = "default"
  region = "ap-northeast-1"
}

module "web_instance" {
  source = "./modules/ec2-instance"

  instance_type = "t2.micro"
  ami = "ami-0f415cc2783de6675"
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  instance_count = 2 
  subnet_id           = data.aws_subnet.default_az1.id
 
}

data "aws_subnet" "default_az1" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-northeast-1a"]
  }
}

data "aws_subnet" "default_az2" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-northeast-1c"]
  }
}

resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app" {
  name               = "my-app-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets	     = [data.aws_subnet.default_az1.id, data.aws_subnet.default_az2.id]
}


resource "aws_lb_target_group" "app" {
  name     = "my-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group_attachment" "app" {
  count            = length(module.web_instance.instance_ids) 
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = module.web_instance.instance_ids[count.index]
  port             = 80
}


resource "aws_default_vpc" "default" {
}

resource "aws_security_group" "demo_sg" {
  name   = "demo-sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.default_az1.cidr_block]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.default_az1.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ec2_instance_connect_endpoint" "my-endpoint" {
  subnet_id         = data.aws_subnet.default_az1.id
  security_group_ids = [aws_security_group.demo_sg.id]
}
