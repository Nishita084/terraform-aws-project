
# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami             = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.ec2_sg.name]
  key_name        = "my-key-pair"

  tags = {
    Name = "WebServer"
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2_sg.id]
  subnets           = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
}

# Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier  = [aws_subnet.public_subnet.id]
  desired_capacity     = 2
  min_size            = 1
  max_size            = 3
  launch_configuration = aws_launch_configuration.web_lc.id
}

# Launch Configuration
resource "aws_launch_configuration" "web_lc" {
  name          = "web-launch-config"
  image_id      = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

# RDS (MySQL Database)
resource "aws_db_instance" "rds_mysql" {
  allocated_storage    = 20
  engine              = "mysql"
  instance_class      = "db.t2.micro"
  username           = "admin"
  password           = "password123"
  publicly_accessible = false
  skip_final_snapshot = true
}

# S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-terraform-bucket-12345"
}

# IAM Role
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
