provider "aws" {
  region = "us-west-1"
}

module "vpc" {
  source         = "../../modules/vpc"
  cidr_block     = "10.0.0.0/16"
  subnet_a_cidr  = "10.0.1.0/24"
  subnet_b_cidr  = "10.0.2.0/24"
  az_a            = "us-west-1a"
  az_b            = "us-west-1b"
}

module "ec2" {
  source        = "../../modules/ec2"
  ami           = "ami-xxxxxx"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.subnet_a_id
  name          = "Secondary EC2"
}

module "rds" {
  source                   = "../../modules/rds"
  storage                  = 20
  storage_type             = "gp2"
  db_instance_class        = "db.t2.micro"
  engine_version           = "8.0"
  db_instance_identifier   = "secondary-db"
  db_username              = "admin"
  db_password              = "password"
  db_name                  = "secondarydb"
  multi_az                 = true
  security_group_id        = "sg-xxxxxx"
  az                       = "us-west-1a"
  az_replica               = "us-west-1b"
  db_instance_identifier_replica = "secondary-db-replica"
}

module "s3" {
  source        = "../../modules/s3"
  bucket_name   = "secondary-backup-bucket"
  replica_bucket = "primary-backup-bucket"
}
