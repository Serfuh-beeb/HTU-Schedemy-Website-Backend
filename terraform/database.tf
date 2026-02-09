# --- 1. Database Subnet Group ---
# This tells RDS: "You are allowed to live in these two private subnets."
resource "aws_db_subnet_group" "schedemy_db_subnet_group" {
  name       = "schedemy-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "schedemy-db-subnet-group"
  }
}

# --- 2. Database Security Group ---
# This is the firewall for the Database.
# It says: "Only allow traffic from the App Servers on port 3306."
resource "aws_security_group" "db_sg" {
  name        = "schedemy-db-sg"
  description = "Allow MySQL traffic from App Servers"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "MySQL from App SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id] # Only App Servers can enter
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "schedemy-db-sg" }
}

# --- 3. The Database Instance (RDS) ---
resource "aws_db_instance" "schedemy_db" {
  identifier           = "schedemy-prod-db"
  allocated_storage    = 20    # 20 GB of space (Free Tier eligible)
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0" # Standard MySQL version
  instance_class       = "db.t3.micro" # Free Tier eligible instance
  db_name              = "schedemy"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = null # Use AWS default for the engine version
  skip_final_snapshot  = true # Skip backup when deleting (for labs only)
  
  # Networking
  db_subnet_group_name   = aws_db_subnet_group.schedemy_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az               = false # Set to 'true' for Distinction (costs money), 'false' for Free Tier
  publicly_accessible    = false # Security Best Practice: NO public access
}
