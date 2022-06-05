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
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDodeb5lhvA9KgSXxxKRYvwsrStUl6MBocXq5/TLz6e9YvT5DBJeXzLrxsgWxHRKynXdw/2speazixceIE5KKPuKJdO9U85XcQyodYarOyjyWTiB6K7hWOmgL25x/wkWaLI5wW/jU60T6RraYDZNfTO8wloYlzr0mV0AVj9yAwOuhG0cAVJugO8JfMTy4yQXCSJZCmyLyvKbQcRXI34OrkEITaW0tcRMvpufzuui2Cj5AE2IVdorjQ4vvUa8p14shY0IO0LP9CnEO8BECm0BSLoULQVyi3en1KxE4fG2G6LZsiKXwEtTlJmxAMHHj9f2VgojydCjrMAPgDAtEeqGX9c6/QqdrOagZudrLr+MTC7BhS0wo9keJHKxj/0183AN0KlYyft/AAcvetVvxA+/xPn662ED2IAJHcUderxuTUqA3wBlD8+oxAmiI0T9wuDswA6q2x9eYTsNCOE7Jz49QXlUxY5ydHrXCO75iyGj3Z6LU0ifZ339k0yKGQdeCS2/hKCT/HJj3af2yuVXrEh9J7DuD/upXcfMw8JA+33bVYuCbO41m2mQ+QZtjfhfidJ66sJfAMlWEkq4uRd4ZE4wTu0MeY45/kxIqGLiib/Twe7NfNCMPzr9SUD+bTVXfiCRBvNstmmaPefFhlVyEwKdtSyR10o49gCjER/Kx0jG7hoBQ== localhost@ubuntu"
}
