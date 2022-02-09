provider "aws"{
  region = "eu-central-1"
}
resource "aws_instance" "infrastructure"{
  ami="ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ASG.id]
}
resource "aws_security_group" "ASG"{
  name = "My Demo infrastructure"
  description = "In this way i try IAAC"
}
ingress{
  from port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
ingress{
  from port = 9100
  to_port = 9100
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
ingress{
  from port = 8081
  to_port = 8081
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
ingress{
  from port = 8082
  to_port = 8082
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
egress{
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
