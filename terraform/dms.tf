resource "aws_security_group" "ec2_postgres" {
  vpc_id = module.vpc.vpcs.main.id
}

resource "aws_dms_replication_subnet_group" "ec2_postgres" {
  replication_subnet_group_id = "ec2-postgres-dms-replication-subnet-group"
  replication_subnet_group_description = "DMS replication subnet group for EC2-Postgres"
  subnet_ids = [module.vpc.subnets.private_a.id, module.vpc.subnets.private_b.id]
}

resource "aws_dms_replication_instance" "ec2_postgres" {
  multi_az                    = false
  replication_instance_class  = "dms.t3.micro"
  replication_instance_id     = "ec2-postgres-dms-replication-instance"
  replication_subnet_group_id = aws_dms_replication_subnet_group.ec2_postgres.id
  vpc_security_group_ids      = [aws_security_group.ec2_postgres.id]
}

resource "aws_dms_endpoint" "ec2_postgres_source" {
  endpoint_type = "source"
  endpoint_id   = "ec2-postgres-dms-source-endpoint"
  database_name = aws_db_instance.postgres.db_name
  engine_name   = aws_db_instance.postgres.engine
  port          = aws_db_instance.postgres.port
  server_name   = "172.32.67.253"
  password      = var.db_password
  username      = var.db_username
}

resource "aws_dms_endpoint" "ec2_postgres_target" {
  endpoint_type = "target"
  endpoint_id   = "ec2-postgres-dms-target-endpoint"
  database_name = aws_db_instance.postgres.db_name
  engine_name   = aws_db_instance.postgres.engine
  port          = aws_db_instance.postgres.port
  server_name   = aws_db_instance.postgres.address
  password      = var.db_password
  username      = var.db_username
}

resource "aws_dms_replication_task" "ec2_postgres" {
  migration_type           = "full-load"
  start_replication_task   = false
  replication_instance_arn = aws_dms_replication_instance.ec2_postgres.replication_instance_arn
  replication_task_id      = "ec2-postgres-dms-replication-task"
  source_endpoint_arn      = aws_dms_endpoint.ec2_postgres_source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.ec2_postgres_target.endpoint_arn
  table_mappings           = "{\"rules\":[]}"
}
