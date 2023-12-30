terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure AWS provider
provider "aws" {
  region     = "us-east-1"
  access_key = "ABIA3WSFDQD7GAS6OH6Z"
  secret_key = "bJW0igPBec90Xy2qvbFjwh3ty9fG+D2kEDOCdc/5"
}


# Create security group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "for jenkins instance"
  vpc_id      = "vpc-0205b13bc7031906c"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "jenkins_sg"
  }
}

# User data template file
data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
}

# EC2 instance with user data 
resource "aws_instance" "jenkins_instance" {
  ami                         = "ami-0c7217cdde317cfec" # Ubuntu 22.04 AMI 
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-0ddf6a321863bc0fe"
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  key_name                    = "us-east-kp"
  user_data                   = data.template_file.user_data.rendered
  associate_public_ip_address = true
  tags = {
    "jenkins-instance" = "true"
  }
}

resource "aws_s3_bucket" "jenkins-bucket" {
  bucket = "otis-jenkins-bucket-123"
}

resource "aws_s3_bucket_ownership_controls" "jenkins-bucket-ownership" {
  depends_on = [aws_s3_bucket.jenkins-bucket]
  bucket     = aws_s3_bucket.jenkins-bucket.bucket
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "jenkins-bucket-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.jenkins-bucket-ownership]

  bucket = "otis-jenkins-bucket-123"
  acl    = "private"
}


output "public_ip" {
  value = aws_instance.jenkins_instance.public_ip
}
