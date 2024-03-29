data "aws_vpc" "default" {
  id = var.vpc_id
}
data "aws_subnet" "default" {
  id = var.subnet_id
}

data "aws_ami" "window" {
  most_recent = true

  filter {
    name   = "name"
    # values = ["GZ-U2GAME01-AMI-Final-20230616"]
    values = ["Golfzon-PoC-packer-win-aws-init-focal-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099984158942"] # my accont id
}

resource "aws_instance" "win" {
  count         = length(var.host_name)
  # ami           = "ami-09493d418f1ae1797" # manual ami
 ami           = data.aws_ami.window.id
  instance_type = "t3.small"
  subnet_id     = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.win.id]
  associate_public_ip_address = true
  # key_name      = var.ec2_key
  tags = {
    Name = "${var.prefix}-${element(var.host_name, count.index)}"
  }
  user_data = templatefile("${path.module}/user_data.tftpl", { 
    admin_password = var.admin_password,
    host_name = element(var.host_name, count.index),
    ad_dns = var.ad_dns,
    domain = var.domain,
    ad_username = var.ad_username,
    ad_password = var.ad_password
  })
}