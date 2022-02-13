provider "aws"{
  
  region = "eu-central-1"
}

resource "aws_instance" "infrastructure"{


  ami = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ASG.id]
  provisioner "local-exec" {
    command = "echo ${aws_instance.infrastructure.public_ip} >> /tmp/private_ips.txt"
  }
  associate_public_ip_address = true
  key_name         = "ssh-key"
  user_data = <<EOF
  #!/bin/sh

  set -o errexit
  set -o nounset

  IFS=$(printf '\n\t')

  # Docker
  sudo apt remove --yes docker docker-engine docker.io containerd runc || true
  sudo apt update
  sudo apt --yes --no-install-recommends install apt-transport-https ca-certificates
  wget --quiet --output-document=- https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository --yes "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable"
  sudo apt update
  sudo apt --yes --no-install-recommends install docker-ce docker-ce-cli containerd.io
  sudo usermod --append --groups docker "$USER"
  sudo systemctl enable docker
  printf '\nDocker installed successfully\n\n'

  printf 'Waiting for Docker to start...\n\n'
  sleep 5

  # Docker Compose
  sudo wget --output-document=/usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/$(wget --quiet --output-document=- https://api.github.com/repos/docker/compose/releases/latest | grep --perl-regexp --only-matching '"tag_name": "\K.*?(?=")')/run.sh"
  sudo chmod +x /usr/local/bin/docker-compose
  sudo wget --output-document=/etc/bash_completion.d/docker-compose "https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose"
  printf '\nDocker Compose installed successfully\n\n'
  
  EOF
}
locals {
  ports_in = [
    22,
    443,
    80,
    9100,
    8081,
    8082
  ]
  ports_out = [
    0
  ]
}
resource "aws_security_group" "ASG"{
  name = "My Demo infrastructure"
  description = "In this way i try IAAC"




 dynamic "ingress" {
    for_each = toset(local.ports_in)
    content {
      description      = "Inbound ports"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = toset(local.ports_out)
    content {
      from_port        = egress.value
      to_port          = egress.value
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }
  
}
resource "aws_key_pair" "ssh-key" {
    key_name   = "ssh-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHI9CQY1nU+tI50t2VZ8w8ErtMwfB2CDhjz0OSg19gaRYc3eAHtp7adFShasRACQ0sy1F3aXSrThuALM+3voJLUpARxELjYy7Q2Q66R3PeFp1dnXo4e/61Fo/wTnwgiPISeIXeKFzgZZrvl8hd3+/+Y1wXQRif4rE+R/0YDvjHqwcfylNEiRKF4jHX+tPcXt1g5sX3glaesNseAOw62kwAkxSbcbJloUjqVwUKnSPGp6q+gIlXyWgFhWSnh2yxihEdzAUBLefP3XrqeNzEiMfq7QbyRryp1+7GM+JPAxX6G17tWuuZ5y6y4T3+MEXqbXlMsKcc8nbo9/2pZ1pVXWht0AQZEIImzYf3Lj9Knte05A0FwRMFlg+EWqwtFE2ZWdHe3GUQe/29y1wx5DcUEsOCgL2v0GeGtxu1TGVJKZ9d8BJnD0YfNF8iZnkXvJUtVUtMUqE7Q5RsRKi/otVYlGNBu2i8rDe/2qC4883yQsXOqWbXVIPP1c+8OvoYzRCXfrc= root@vm1374270"
}
