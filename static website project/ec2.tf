############################################
# Always fetch the latest Amazon Linux 2 AMI (free to use, no license fee)
############################################
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

############################################
# Optional key pair (only created if you pass a public key in via TF_VAR)
# Most people can skip this entirely and use EC2 Instance Connect instead,
# which is free and doesn't need a key pair.
############################################

locals {
  key_name = var.ssh_key_name
}

############################################
# Public EC2 instance - simple web server
############################################
resource "aws_instance" "public_web" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  key_name                    = local.key_name
  associate_public_ip_address = true

  # Free tier note: EBS root volume defaults to 8 GiB gp2/gp3, which is
  # within the 30 GB-month of EBS storage included in the Free Tier.
  root_block_device {
    volume_type = "gp3"
    volume_size = 8
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<h1>Hello from the public EC2 instance in ${var.project_name}</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.project_name}-public-ec2"
  }
}

############################################
# Optional private EC2 instance (disabled by default - see variables.tf)
############################################
resource "aws_instance" "private_app" {
  count = var.create_private_instance ? 1 : 0

  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = local.key_name

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
  }

  tags = {
    Name = "${var.project_name}-private-ec2"
  }
}
