resource "aws_instance" "aws_ubuntu" {

  count = var.instance_count

  instance_type = var.instance_type 
  ami = var.ami
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id          = var.subnet_id
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Hello, world!</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.name_prefix}-${count.index}"
  }

}

