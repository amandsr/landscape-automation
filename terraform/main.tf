resource "aws_key_pair" "landscape_key" {
  key_name   = "landscape"
  public_key = var.ssh_public_key
}

resource "aws_security_group" "landscape_sg" {
  name        = "landscape_sg"

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

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_instance" "landscape" {
  ami           = "ami-020cba7c55df1f615" # Ubuntu 24
  instance_type = var.instance_type
  key_name      = aws_key_pair.landscape_key.id
  security_groups = [aws_security_group.landscape_sg.name]

  tags = {
    Name = "LandscapeServer"
  }
}
