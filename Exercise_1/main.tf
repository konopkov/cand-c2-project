// Designate a cloud provider, region, and credentials
provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "terraform"
  region                  = "us-east-1"
}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

// Provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "T2" {
  count                   = 4
  ami                     = data.aws_ami.ami.id
  instance_type           = "t2.micro"
  subnet_id               = "subnet-38cf4a4e"
  tags = {
    Name                  = "Udacity T2"
  }
}

// Provision 2 m4.large EC2 instances named Udacity M4
resource "aws_instance" "M4" {
  count                   = 2
  ami                     = data.aws_ami.ami.id
  instance_type           = "m4.large"
  subnet_id               = "subnet-38cf4a4e"
  tags = {
    Name                  = "Udacity M4"
  }
}
