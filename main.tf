provider aws {
  profile = "default"
  region = "ap-northeast-1"
}

resource "aws_instance" "aws_ubuntu" {
  instance_type = "t2.micro"
  ami = "ami-0f415cc2783de6675"
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Hello, world! NGINX is running on Ubuntu 22</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "HelloWorldWebServer"
  }

}

resource "aws_default_vpc" "default" {
}

resource "aws_security_group" "demo_sg" {
  name = "demo_sp"
  vpc_id = aws_default_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_80_ipv4" {
  security_group_id = aws_security_group.demo_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_22_ipiv4" {
  security_group_id = aws_security_group.demo_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.demo_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

output "aws_instance_public_dns" {
  value = aws_instance.aws_ubuntu.public_dns
}
