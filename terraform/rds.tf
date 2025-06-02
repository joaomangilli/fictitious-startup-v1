data "aws_rds_engine_version" "postgres" {
  engine = "postgres"
}

resource "aws_db_parameter_group" "postgres" {
  family = data.aws_rds_engine_version.postgres.parameter_group_family

  parameter {
    name  = "rds.force_ssl"
    value = 0
  }
}

resource "aws_security_group" "postgres" {
  vpc_id = module.vpc.vpcs.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
}

resource "aws_db_subnet_group" "postgres" {
  name       = "mvp-postgres-subnet-group"
  subnet_ids = [module.vpc.subnets.private_a.id]
}

resource "aws_db_instance" "postgres" {
  db_name                = "mvp"
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]
  parameter_group_name   = aws_db_parameter_group.postgres.name
}
