resource "aws_security_group" "allow_tls" {
  name        = "ec2-sg"
  description = "ec2-sg"
  vpc_id      = var.vpc_id
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.load-balancer-sg]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow 22"
  }
}


resource "aws_instance" "ec2_instances" {

  count = 3
  ami = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = "master"
  security_groups        = [aws_security_group.allow_tls.id]
  subnet_id              = var.private_subnets[count.index]
  availability_zone      = var.azs[count.index]

  tags = {

    Name = "instance-${count.index + 1}"
    Terraform   = "true"
    Environment = "dev"
    
  }
}
output "instance_ids" {
  value = [for instance in aws_instance.ec2_instances : instance.id]
}
 
resource "aws_instance" "public_instance" {
  ami = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = "master"
  security_groups        = [aws_security_group.allow_tls.id]
  subnet_id              = var.pub_azs[0]
  availability_zone      = var.azs[0]
  associate_public_ip_address = true

  tags = {

    Name = "Bastion-host"
    Terraform   = "true"
    Environment = "dev"
    
  }
}
