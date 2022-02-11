provider "aws"{
  
  region = "eu-central-1"
}

resource "aws_instance" "infrastructure"{


  ami = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ASG.id]
}
locals {
  ports_in = [
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
 
