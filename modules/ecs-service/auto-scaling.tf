locals {
  autoscaling_enabled = var.autoscaling.enabled
  scheduled_enabled   = var.autoscaling.enabled && var.autoscaling.scheduled != null
}

resource "aws_appautoscaling_target" "ecs_service_target" {
  count              = local.autoscaling_enabled ? 1 : 0
  max_capacity       = var.autoscaling.max_capacity
  min_capacity       = var.autoscaling.min_capacity
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.this]

  tags = {
    Name = "${var.cluster_name}-ecs-service-autoscaling-target"
  }
}

resource "aws_appautoscaling_policy" "cpu" {
  count              = local.autoscaling_enabled ? 1 : 0
  name               = "${var.cluster_name}-${var.service_name}-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.autoscaling.cpu_target
    scale_in_cooldown  = var.autoscaling.scale_in_cooldown
    scale_out_cooldown = var.autoscaling.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "memory" {
  count              = local.autoscaling_enabled ? 1 : 0
  name               = "${var.cluster_name}-${var.service_name}-memory-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.autoscaling.memory_target
    scale_in_cooldown  = var.autoscaling.scale_in_cooldown
    scale_out_cooldown = var.autoscaling.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

resource "aws_appautoscaling_scheduled_action" "scale_in" {
  count              = local.scheduled_enabled ? 1 : 0
  name               = "${var.cluster_name}-${var.service_name}-scale-in"
  service_namespace  = aws_appautoscaling_target.ecs_service_target[0].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_service_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target[0].scalable_dimension
  schedule           = var.autoscaling.scheduled.scale_in_cron

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }

  depends_on = [aws_appautoscaling_target.ecs_service_target]
}

resource "aws_appautoscaling_scheduled_action" "scale_out" {
  count              = local.scheduled_enabled ? 1 : 0
  name               = "${var.cluster_name}-${var.service_name}-scale-out"
  service_namespace  = aws_appautoscaling_target.ecs_service_target[0].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_service_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target[0].scalable_dimension
  schedule           = var.autoscaling.scheduled.scale_out_cron

  scalable_target_action {
    min_capacity = var.autoscaling.min_capacity
    max_capacity = var.autoscaling.max_capacity
  }

  depends_on = [aws_appautoscaling_target.ecs_service_target]
}
