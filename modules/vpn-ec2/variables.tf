variable "name" {
  description = "Name of the EC2 instance and security group"
  type        = string
}

variable "ami_id" {
  description = "AMI ID (e.g. Ubuntu 22.04)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key name for EC2"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID where EC2 will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "associate_public_ip" {
  description = "Associate a public IP address"
  type        = bool
  default     = true
}

variable "user_data" {
  description = "User data script to bootstrap EC2"
  type        = string
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Root volume type (gp2, gp3, etc)"
  type        = string
  default     = "gp3"
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
