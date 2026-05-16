output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.custom_vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.custom_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs in the VPC"
  value       = aws_subnet.custom_public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs in the VPC"
  value       = aws_subnet.custom_private[*].id
}

output "network" {
  description = "Network context object for consumption by compute modules"
  value = {
    vpc_id             = aws_vpc.custom_vpc.id
    vpc_cidr           = aws_vpc.custom_vpc.cidr_block
    public_subnet_ids  = aws_subnet.custom_public[*].id
    private_subnet_ids = aws_subnet.custom_private[*].id
  }
}