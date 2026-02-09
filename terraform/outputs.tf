# --- Outputs to use after terraform apply ---

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.schedemy_alb.dns_name
}

output "db_endpoint" {
  description = "RDS MySQL endpoint (host:port)"
  value       = aws_db_instance.schedemy_db.endpoint
}

output "db_address" {
  description = "RDS MySQL hostname (without port)"
  value       = aws_db_instance.schedemy_db.address
}

output "db_name" {
  description = "Name of the database"
  value       = aws_db_instance.schedemy_db.db_name
}

output "db_username" {
  description = "Database master username"
  value       = aws_db_instance.schedemy_db.username
  sensitive   = true
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main_vpc.id
}
