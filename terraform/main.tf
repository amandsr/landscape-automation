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
  root_block_device {
    volume_size = 20 # Specify the desired size in GB
    volume_type = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "LandscapeServer"
  }
  user_data = <<-EOF
    #!/bin/bash
    # This script will run as root on the EC2 instance upon launch

    # 1. Create ansible user and set password
    useradd -s /bin/bash -m ansible
    echo ansible:ansible | chpasswd

    # 2. Create .ssh directory and set permissions for ansible user
    mkdir /home/ansible/.ssh
    chown -R ansible:ansible /home/ansible/.ssh
    chmod 700 /home/ansible/.ssh

    # 3. Add SSH public key from Terraform variable to authorized_keys
    # IMPORTANT: The public key must be on a single line.
    echo "${var.ssh_public_key}" > /home/ansible/.ssh/authorized_keys
    chown ansible:ansible /home/ansible/.ssh/authorized_keys
    chmod 644 /home/ansible/.ssh/authorized_keys

    # 4. Enable PasswordAuthentication for SSH (Caution: Less secure for production)
    # Use '^#\?PasswordAuthentication' to match commented or uncommented lines
    sed -i '/^#\\?PasswordAuthentication \\(yes\\|no\\)/c\\PasswordAuthentication yes' /etc/ssh/sshd_config
    # Remove any SSHD config snippets that might override this
    rm -f /etc/ssh/sshd_config.d/*

    # 5. Restart SSH service
    systemctl restart ssh

    # 6. Grant NOPASSWD sudo privileges to the ansible user
    # Safer to use a file in /etc/sudoers.d/
    echo "ansible ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/ansible_sudo
    chmod 0440 /etc/sudoers.d/ansible_sudo # Ensure correct permissions for sudoers file
  EOF
}
