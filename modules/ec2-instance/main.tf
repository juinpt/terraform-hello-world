resource "aws_instance" "aws_ubuntu" {

  count = var.instance_count

  instance_type = var.instance_type 
  ami = var.ami
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id          = var.subnet_id

  user_data = templatefile("${path.module}/user_data.sh.tmpl", {
    name =  "${var.name_prefix}-${count.index}"
  })

  tags = {
    Name = "${var.name_prefix}-${count.index}"
  }

}

