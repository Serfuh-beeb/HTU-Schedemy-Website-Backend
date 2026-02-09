# --- 1. Load Balancer ---
resource "aws_lb" "schedemy_alb" {
  name               = "schedemy-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = { Name = "schedemy-alb" }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.schedemy_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.schedemy_tg.arn
  }
}

resource "aws_lb_target_group" "schedemy_tg" {
  name     = "schedemy-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/" # Checks if app is responding
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
    port                = 8080
  }

  # Prevents "ResourceInUse" errors when changing ports
  lifecycle {
    create_before_destroy = true
  }
}

# --- 2. Launch Template ---
resource "aws_launch_template" "schedemy_lt" {
  name_prefix   = "schedemy-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
  }

  # Install Java 17, Maven, and run a placeholder health-check responder
  # until Ansible deploys the real Spring Boot app
  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -e
              apt-get update -y
              apt-get install -y openjdk-17-jdk maven docker.io git acl
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu

              # Placeholder: keep ALB health checks happy until Ansible deploys
              docker run -d -p 8080:80 nginx
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Schedemy-App-Server"
      Role = "SchedemyWebServer"
    }
  }
}

# --- 3. Auto Scaling Group ---
resource "aws_autoscaling_group" "schedemy_asg" {
  name                = "schedemy-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  target_group_arns = [aws_lb_target_group.schedemy_tg.arn]

  launch_template {
    id      = aws_launch_template.schedemy_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Schedemy-App-Instance"
    propagate_at_launch = true
  }
}