resource "aws_db_instance" "this" {
  allocated_storage    = var.storage
  storage_type         = var.storage_type
  instance_class       = var.db_instance_class
  engine               = "mysql"
  engine_version       = var.engine_version
  identifier           = var.db_instance_identifier
  username             = var.db_username
  password             = var.db_password
  db_name              = var.db_name
  multi_az             = var.multi_az
  availability_zone    = var.az
  vpc_security_group_ids = [var.security_group_id]
}

resource "aws_db_instance" "replica" {
  replicate_source_db  = aws_db_instance.this.id
  instance_class       = var.db_instance_class
  engine               = "mysql"
  engine_version       = var.engine_version
  identifier           = var.db_instance_identifier_replica
  multi_az             = var.multi_az
  availability_zone    = var.az_replica
}
