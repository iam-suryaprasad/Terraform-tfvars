provider "aws" {
  region = var.region_name
}

resource "aws_vpc" "Terra-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_tags
  }
}

resource "aws_subnet" "Public-subnet" {
  vpc_id                  = aws_vpc.Terra-vpc.id
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.subnet_az

  tags = {
    Name = var.subnet_tags
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Terra-vpc.id

  tags = {
    Name = var.igw_tags
  }
}

resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.Terra-vpc.id

  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.rt_tags
  }
}


resource "aws_route_table_association" "RT_association" {
  subnet_id      = aws_subnet.Public-subnet.id
  route_table_id = aws_route_table.Public_RT.id
}

resource "aws_security_group" "allow_tls" {

  vpc_id = aws_vpc.Terra-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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

  tags = {
    Name = var.sg_tags
  }

}


resource "aws_instance" "web-1" {
  ami                         = var.ec2_ami
  availability_zone           = var.ec2_az
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.Public-subnet.id
  key_name                    = var.ec2_key_name
  vpc_security_group_ids         = ["${aws_security_group.allow_tls.id}"]
  associate_public_ip_address = true
  tags = {
    Name = "Prod Server"
    Env  = "Prod"

  }
}
