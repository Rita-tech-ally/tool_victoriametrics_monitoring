resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = var.public_subnets

  tags = {
    Name = "${var.project_name}-${var.environment}-app-alb"
  }
}

resource "aws_lb_target_group" "vminsert" {
  name     = "${var.environment}-tg-vminsert"
  port     = 8480
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    port                = "8480"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "vmselect" {
  name     = "${var.environment}-tg-vmselect"
  port     = 8481
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    port                = "8481"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "vminsert" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vminsert.arn
  }
}

resource "aws_lb_listener" "vmselect" {
  load_balancer_arn = aws_lb.main.arn
  port              = "81"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vmselect.arn
  }
}

resource "aws_autoscaling_group" "app" {
  desired_capacity    = var.app_asg_desired
  max_size            = 2
  min_size            = var.app_asg_min
  vpc_zone_identifier = slice(var.private_subnets, 0, 2)
  target_group_arns = [
    aws_lb_target_group.vminsert.arn,
    aws_lb_target_group.vmselect.arn
  ]

  launch_template {
    id      = var.app_launch_template_id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-app"
    propagate_at_launch = true
  }
}

resource "aws_lb_target_group" "grafana" {
  name     = "${var.environment}-tg-grafana"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/api/health"
    port                = "3000"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "grafana" {
  target_group_arn = aws_lb_target_group.grafana.arn
  target_id        = var.grafana_instance_id
  port             = 3000
}

resource "aws_lb_listener_rule" "grafana" {
  listener_arn = aws_lb_listener.vminsert.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }

  condition {
    host_header {
      values = ["grafana.*"]
    }
  }
}