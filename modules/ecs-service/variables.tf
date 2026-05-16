variable "cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster (used for autoscaling resource ID)"
  type        = string
  default     = "my-ecs-cluster"
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "my-ecs-service"
}

variable "desired_count" {
  description = "Desired number of tasks in the ECS service"
  type        = number
  default     = 1
}

variable "launch_type" {
  description = "Launch type for the ECS service (EC2 or FARGATE)"
  type        = string
  default     = "EC2"
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percent for ECS service deployment"
  type        = number
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "Maximum percent for ECS service deployment"
  type        = number
  default     = 200
}

variable "network" {
  description = "Network context from the networking module"
  type = object({
    vpc_id             = string
    vpc_cidr           = string
    public_subnet_ids  = list(string)
    private_subnet_ids = list(string)
  })
}

variable "security_groups" {
  description = "Additional security group IDs to attach to the ECS service"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP address to the ECS service"
  type        = bool
  default     = false
}

variable "task_definition_family" {
  description = "Family name for the ECS task definition"
  type        = string
  default     = "my-task-family"
}

variable "requires_compatibilities" {
  description = "List of launch types that the task definition is compatible with"
  type        = list(string)
  default     = ["EC2"]
}

variable "network_mode" {
  description = "Network mode for the task definition"
  type        = string
  default     = "awsvpc"
}

variable "cpu" {
  description = "CPU units for the task definition"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory for the task definition"
  type        = string
  default     = "512"
}

variable "operating_system_family" {
  description = "Operating system family for the task definition"
  type        = string
  default     = "LINUX"
}

variable "cpu_architecture" {
  description = "CPU architecture for the task definition"
  type        = string
  default     = "X86_64"
}

variable "allowed_actions" {
  description = "IAM actions granted to the task role. Empty list creates no policy."
  type        = list(string)
  default     = []
}

variable "allowed_resources" {
  description = "IAM resources the task role may act on"
  type        = list(string)
  default     = []
}

variable "containers" {
  description = "Containers to run in the task definition"
  type = list(object({
    name      = string
    image     = string
    cpu       = number
    memory    = number
    essential = bool
  }))
  default = [
    {
      name      = "my-container"
      image     = "my-image:latest"
      cpu       = 256
      memory    = 512
      essential = true
    }
  ]
}

variable "container_port" {
  description = "Port the container listens on. Required when is_loadbalancer_fronted is true."
  type        = number
  default     = null
}

variable "health_check" {
  description = "Container health check configuration"
  type = object({
    command      = list(string)
    interval     = number
    timeout      = number
    retries      = number
    start_period = number
  })
  default = null
}

variable "is_loadbalancer_fronted" {
  description = "Whether the ECS service is fronted by a load balancer"
  type        = bool
  default     = false
}

variable "lb_sg_id" {
  description = "Security group ID of the load balancer (required when is_loadbalancer_fronted is true)"
  type        = string
  default     = null
}

variable "lb_target_group_arn" {
  description = "ARN of the load balancer target group (required when is_loadbalancer_fronted is true)"
  type        = string
  default     = null
}

variable "autoscaling" {
  description = "Autoscaling configuration. Set enabled = true to activate."
  type = object({
    enabled            = bool
    min_capacity       = optional(number, 1)
    max_capacity       = optional(number, 3)
    cpu_target         = optional(number, 80)
    memory_target      = optional(number, 80)
    scale_in_cooldown  = optional(number, 60)
    scale_out_cooldown = optional(number, 60)
    scheduled = optional(object({
      scale_in_cron  = optional(string, "cron(30 21 ? * MON-FRI *)")
      scale_out_cron = optional(string, "cron(30 12 ? * MON-FRI *)")
    }), null)
  })
  default = {
    enabled = false
  }
}
