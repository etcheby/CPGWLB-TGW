###################################
###### Spoke-1 Security Group #####
###################################

resource "aws_security_group" "spoke1_sg" {
  description = "Jump Server SG to access test instance in Spoke1-2A VPC"
  vpc_id      = aws_vpc.spoke1_vpc.id

  # SSH access from Allowed_Sources
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from Allowed Sources
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Spoke1 Jump-SG"
  }

}

resource "aws_instance" "spoke1_instance" {
  ami                         = "ami-0a36eb8fadc976275"
  instance_type               = "t2.nano"
  availability_zone           = var.spoke1_subnet_az
  subnet_id                   = aws_subnet.spoke1_subnet.id 
  key_name                    = var.key_name
  associate_public_ip_address = "true"
  private_ip                  = "10.2.0.10"
  vpc_security_group_ids      = [aws_security_group.spoke1_sg.id]

  tags = {
    Name = "AMLinux-Spoke1"
  }
}