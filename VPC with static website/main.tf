####################################
# VPC
####################################

resource "aws_vpc" "lab" {

  cidr_block           = "10.0.0.0/16"

  enable_dns_hostnames = true

  tags = {
    Name = "Lab-VPC"
  }
}

####################################
# Internet Gateway
####################################

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "Lab-IGW"
  }
}

####################################
# Public Subnet
####################################

resource "aws_subnet" "public" {

  vpc_id                  = aws_vpc.lab.id

  cidr_block              = "10.0.1.0/24"

  availability_zone       = "${var.aws_region}a"

  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet"
  }
}

####################################
# Route Table
####################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.lab.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id

  }

  tags = {
    Name = "Public-RT"
  }
}

resource "aws_route_table_association" "public" {

  subnet_id      = aws_subnet.public.id

  route_table_id = aws_route_table.public.id

}

####################################
# Security Group
####################################

resource "aws_security_group" "web" {

  name   = "Web-SG"

  vpc_id = aws_vpc.lab.id

  ingress {

    description = "RDP"

    from_port = 3389

    to_port = 3389

    protocol = "tcp"

    cidr_blocks = [var.my_ip]

  }

  ingress {

    description = "HTTP"

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "HTTPS"

    from_port = 443

    to_port = 443

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {

    Name = "Web-SG"

  }

}

####################################
# Latest Windows Server 2022 AMI
####################################

data "aws_ami" "windows" {

  most_recent = true

  owners = ["amazon"]

  filter {

    name = "name"

    values = ["Windows_Server-2022-English-Full-Base-*"]

  }

}

####################################
# EC2 Instance
####################################

resource "aws_instance" "web" {

  ami = data.aws_ami.windows.id

  instance_type = "t3.micro"

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  key_name = var.key_name

  associate_public_ip_address = true

  user_data = file("userdata.ps1")

  root_block_device {

    volume_size = 30

    volume_type = "gp3"

  }

  tags = {

    Name = "Windows-WebServer"

  }

}