variable "cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
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

variable "security_groups" {
  description = "List of security group IDs for the ECS service"
  type        = list(string)
  default     = []
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

variable "vpc_id" {
  description = "VPC ID where the ECS cluster will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS cluster"
  type        = list(string)
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
  description = "List of allowed actions for the ECS task definition"
  type        = list(string)
  default     = ["*"]
}

variable "allowed_resources" {
  description = "List of allowed resources for the ECS task definition"
  type        = list(string)
  default     = ["*"]
}

variable "containers" {
  description = "List of containers for the ECS task definition"
  type = list(object({
    name        = string
    image       = string
    cpu         = number
    memory      = number
    essential   = bool
    health_check = object({
      command     = list(string)
      interval    = number
      timeout     = number
      retries     = number
      startPeriod = number
    })
    port_mappings = list(object({
      container_port = number
      host_port      = number
      protocol       = string
    }))
  }))
  default = [ {
    name        = "my-container"
    image       = "my-image:latest"
    cpu         = 256
    memory      = 512
    essential   = true
    environment = {
      MY_ENV_VAR = "my_value"
    }
    health_check = {
      command     = [ "CMD-SHELL", "curl -f http://localhost:8000/health || exit 1" ]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
    port_mappings = [
      {
        container_port = 80
        host_port      = 80
        protocol       = "tcp"
      }
    ]
  } ]
}

variable "is_loadbalancer_fronted" {
  description = "Whether the ECS service is fronted by a load balancer"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "lb_sg_id" {
  description = "List of security group IDs for the ECS service"
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP address to the ECS service"
  type        = bool
  default     = false
}

variable "lb_target_group_arn" {
  description = "ARN of the load balancer target group"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "my-ecs-cluster"
}

variable "min_capacity" {
  description = "Minimum number of tasks for the ECS service"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks for the ECS service"
  type        = number
  default     = 3
}

variable "enable_autoscaling" {
  description = "Enable auto scaling for the ECS service"
  type        = bool
  default     = true
}

variable "target_cpu_value" {
  description = "Target value for the ECS service auto scaling"
  type        = number
  default     = 80
}
variable "target_memory_value" {
  description = "Target value for the ECS service auto scaling"
  type        = number
  default     = 80
}

variable "scale_in_cooldown" {
  description = "Cooldown period after scaling in"
  type        = number
  default     = 60
}

variable "scale_out_cooldown" {
  description = "Cooldown period after scaling out"
  type        = number
  default     = 60
}