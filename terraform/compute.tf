# --- 1. The Application Load Balancer (ALB) ---
# This is the "Front Door" of your application.
resource "aws_lb" "schedemy_alb" {
  name               = "schedemy-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = { Name = "schedemy-alb" }
}

# Listener: Listens for traffic on Port 80
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.schedemy_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.schedemy_tg.arn
  }
}

# Target Group: A list of servers the ALB sends traffic to
resource "aws_lb_target_group" "schedemy_tg" {
  name     = "schedemy-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/" # Checks if the homepage is loading
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

# --- 2. The Launch Template ---
# This defines the "Blueprint" for every server.
resource "aws_launch_template" "schedemy_lt" {
  name_prefix   = "schedemy-lt-"
  image_id      = "ami-04b70fa74e45c3917" # Ubuntu 24.04 LTS (us-east-1)
  instance_type = "t3.micro"

  # Networking
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # IAM Profile (Allows server to talk to SSM/ECR)
  # We will add the actual role in the next step, for now leaving blank is okay or we add a placeholder.
  # For this specific run, we'll omit the profile line to keep it simple, 
  # but in a real distinction setup, you'd attach the role here.

  # User Data: The Script that runs on boot
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io awscli
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              # Pull and run a sample container to prove it works
              docker run -d -p 80:80 nginx
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Schedemy-App-Server"
      Role = "SchedemyWebServer" # Crucial for Ansible/Deployment
    }
  }
}

# --- 3. The Auto Scaling Group (ASG) ---
# This manages the fleet of servers.
resource "aws_autoscaling_group" "schedemy_asg" {
  name                = "schedemy-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.private_1.id, aws_subnet.private_2.id] # Launches in PRIVATE subnets

  target_group_arns = [aws_lb_target_group.schedemy_tg.arn] # Connects ASG to ALB

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