resource "aws_appautoscaling_target" "ecs_service_target" {
  count             = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.this]

  tags = {
    Name = "${var.cluster_name}-ecs-service-autoscaling-target"
  }
}

resource "aws_appautoscaling_policy" "ecs_service_scaling_cpu_policy" {
  count                 = var.enable_autoscaling ? 1 : 0
  name                   = "${var.cluster_name}-${var.service_name}-scaling-policy"
  policy_type           = "TargetTrackingScaling"
  resource_id            = aws_appautoscaling_target.ecs_service_target[count.index].resource_id
  scalable_dimension     = aws_appautoscaling_target.ecs_service_target[count.index].scalable_dimension
  service_namespace      = aws_appautoscaling_target.ecs_service_target[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.target_cpu_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_service_scaling_memory_policy" {
  count                 = var.enable_autoscaling ? 1 : 0
  name                   = "${var.cluster_name}-${var.service_name}-scaling-policy"
  policy_type           = "TargetTrackingScaling"
  resource_id            = aws_appautoscaling_target.ecs_service_target[count.index].resource_id
  scalable_dimension     = aws_appautoscaling_target.ecs_service_target[count.index].scalable_dimension
  service_namespace      = aws_appautoscaling_target.ecs_service_target[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.target_memory_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}


resource "aws_appautoscaling_scheduled_action" "scale_in_weekdays" {
  count               = var.enable_scheduled_scaling ? 1 : 0
  name                = "${var.cluster_name}-${var.service_name}-scale-in-weekdays"
  service_namespace   = aws_appautoscaling_target.ecs_service_target[0].service_namespace
  resource_id         = aws_appautoscaling_target.ecs_service_target[0].resource_id
  scalable_dimension  = aws_appautoscaling_target.ecs_service_target[0].scalable_dimension
  schedule            = "cron(30 21 ? * MON-FRI *)" # 18:30 BRT = 21:30 UTC

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }

  depends_on = [aws_appautoscaling_target.ecs_service_target]
}

resource "aws_appautoscaling_scheduled_action" "scale_out_weekdays" {
  count               = var.enable_scheduled_scaling ? 1 : 0
  name                = "${var.cluster_name}-${var.service_name}-scale-out-weekdays"
  service_namespace   = aws_appautoscaling_target.ecs_service_target[0].service_namespace
  resource_id         = aws_appautoscaling_target.ecs_service_target[0].resource_id
  scalable_dimension  = aws_appautoscaling_target.ecs_service_target[0].scalable_dimension
  schedule            = "cron(30 12 ? * MON-FRI *)" # 09:30 BRT = 12:30 UTC

  scalable_target_action {
    min_capacity = 1
    max_capacity = 2
  }

  depends_on = [aws_appautoscaling_target.ecs_service_target]
}


