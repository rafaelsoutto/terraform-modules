output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.custom_vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.custom_vpc.cidr_block
}

# output "subnet_ids" {
#   description = "List of subnet IDs in the VPC"
#   value       = aws_subnet.custom_subnet[*].id
# }

output "public_subnet_ids" {
  description = "List of public subnet IDs in the VPC"
  value       = aws_subnet.custom_public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs in the VPC"
  value       = aws_subnet.custom_private[*].id
}