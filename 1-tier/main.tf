resource "aws_security_group" "terr_lb_security_grp" {
  name        = "lb_security grp"
  description = "port 80"
  vpc_id      = var.vpcId

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws_sg_lb_80"
  }
}

output "lb_security" {
  value = aws_security_group.terr_lb_security_grp.id
}

#creating elastic load balancer
resource "aws_lb" "terr_elb" {
  name               = "web-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terr_lb_security_grp.id ]
  subnets            = var.public_subnet

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "terra_lb_target_grp" {
  name     = "web-target-grp"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpcId

    health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path = "/"
    interval            = 30
  }
}

resource "aws_lb_listener" "port_80" {
  load_balancer_arn = aws_lb.terr_elb.arn
  port              = "80"
  protocol          = "HTTP"

 default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terra_lb_target_grp.arn
  }
}


resource "aws_lb_target_group_attachment" "test" {
  count = 3
  target_group_arn = aws_lb_target_group.terra_lb_target_grp.arn
  target_id        = var.ids[count.index]
  port             = 80
}

output "lb_dns" {
  value = aws_lb.terr_elb.dns_name
}


#launch configuration
resource "aws_launch_configuration" "launch_conf" {
  name_prefix   = "terraform-asg"
  image_id      = "ami-053b0d53c279acc90"
  instance_type = "t3.medium"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_placement_group" "terr_placementGrp" {
  name     = "terraform-asg-placement-grp"
  strategy = "cluster"
}

#creating autoscaling group
resource "aws_autoscaling_group" "terr_asg" {
  name                      = "terraform-asg"
  max_size                  = 5
  min_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 3
  force_delete              = true
  placement_group           = aws_placement_group.terr_placementGrp.id
  launch_configuration      = aws_launch_configuration.launch_conf.name
  vpc_zone_identifier       = var.private_subnets

  initial_lifecycle_hook {
    name                 = "asg-lifecycle"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }

tag {
  key                 = "Environment"
  value               = "Project"
  propagate_at_launch = true
}

  timeouts {
    delete = "15m"
  }
}
