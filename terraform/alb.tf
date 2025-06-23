resource "aws_lb" "web" {
  security_groups = [aws_security_group.web.id]
  subnets         = [module.vpc.subnets.public_a.id, module.vpc.subnets.public_b.id]
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_target_group" "web" {
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = module.vpc.vpcs.main.id
  load_balancing_algorithm_type = "least_outstanding_requests"

  health_check {
    timeout             = 15
    healthy_threshold   = 2
    unhealthy_threshold = 4
  }
}

resource "aws_autoscaling_attachment" "web" {
  autoscaling_group_name = aws_autoscaling_group.web.id
  lb_target_group_arn    = aws_lb_target_group.web.arn
}
