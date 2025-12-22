output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "target_groups" {
  value = { for k, tg in aws_lb_target_group.tg : k => {
    target_group_arn  = tg.arn
    target_group_name = tg.name
    target_port       = tg.port
    target_protocol   = tg.protocol
    target_type       = tg.target_type
    health_check_path = tg.health_check[0].path
    health_check_port = tg.health_check[0].port
  } }
}
