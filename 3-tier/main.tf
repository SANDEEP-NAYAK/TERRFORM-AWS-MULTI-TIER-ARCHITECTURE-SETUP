data "aws_secretsmanager_secret_version" "cred" {
  secret_id = "rds_db_creds"
}

locals {
    db_creds = jsondecode(
        data.aws_secretsmanager_secret_version.cred.secret_string
    )
}

resource "aws_db_instance" "web_db" {
  allocated_storage    = var.storage
  db_name              = var.name
  engine               = var.engine
  engine_version       = var.eng_version
  instance_class       = var.ins_class
  username             = local.db_creds.username
  password             = local.db_creds.password
  skip_final_snapshot  = true
  availability_zone = var.db_az
}