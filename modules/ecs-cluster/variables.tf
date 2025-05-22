variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "my-ecs-cluster"
}

variable "container_insights" {
  description = "Enable container insights for the ECS cluster"
  type        = bool
  default     = true
}
