provider "aws"{
  
  region = "eu-central-1"
}

resource "aws_instance" "infrastructure"{


  ami = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ASG.id]
 
  provisioner "local-exec" {
    command =  "echo ${aws_instance.infrastructure.public_ip} >> /tmp/private_ips.txt"
  }
  user_data =<<EOF
#!/bin/bash

sudo apt-get update -y
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
EOF
  
 
  associate_public_ip_address = true
  key_name         = "ssh-key"
  
}
locals {
  ports_in = [
    22,
    443,
    80,
    9100,
    #8081,
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
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDK68CQqauiDGgXMF+Kjb86pI+UCJSeeC7VFoaGlKOpE8fswN6rXLKpdg8G9ArU2lLdYCG9dPMD5yCYANabOZ1Rl6nHqnnX/RRqdK0MEiHxp9fXX407/vVtMXX3dX8QWNU9MTFZ2Mh7viRlh01NDFfcu4xuN7cEgf8wfAblRtx+wL46cgRguPX1XXueF/jfo3lHG3Qkytwn45alQzGnpdg0dSbaswfmgcVWE2nkxRAu23JnE49N0AJ4PLdu3YTjGKg4IDGMvzq4rxU7229Y+ppMR5lDDdxKK0nqD4jaRHm0+xdrH7COy2k2VhiIzRnsMLVCloW4jMC71XJyxdYallkO00ftnle9rpA8OaC/LuUdGbpa7aXcR29+E+4EeeNxp1Zr/hB4RHusMbbDI6WoNRloHsTAqjERteKCe6HTjEiFXSM9pkF3SsIctgGPMFivwVdGXC1QVXo812aPL1jOCuVcl9JvoM1PM1o4ghFNDL0bxZEUrn9HCZTt7vvat35STt7cgDA8H+vHljmeiudlR3klBm9wl1OLNfjw8soz6/2M4YvLjqvEBwBKDJ5Uo7GY+PtRQzd7CQsVIAX3Fn3FMgMHHwOb7BHH3u9DsTPQl6YFL29JPqDb2YvPlvCWNY8H4J4KNmajZVGJtwZCrl+UT+TyZrBQbAbfRe+Re3jbqCjRBQ== localhost@ubuntu"
}
