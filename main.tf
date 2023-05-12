resource "aws_db_subnet_group" "subnet_group" {

  name = "${var.env}-rds_subnet_group"
  subnet_ids = var.subnet_ids
  tags = merge (local.common_tags, { Name = "${var.env}-rds_subnet_group" } )

}

resource "aws_security_group" "rds" {
  name        = "${var.env}-rds_security_group"
  description = "${var.env}-rds_subnet_group"
  vpc_id = var.vpc_id


  ingress {
    description      = "RDS"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge (local.common_tags, { Name = "${var.env}-rds_security_group" } )

}



resource "aws_rds_cluster" "rds" {
  cluster_identifier                      = "${var.env}-rds-cluster"
  engine_version                          = var.engine_version
  engine                                  = var.engine
  master_username                         = data.aws_ssm_parameter.rds_ADMIN_USER.value
  master_password                         = data.aws_ssm_parameter.rds_ADMIN_PASS.value
  db_subnet_group_name                    = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids                  = [aws_security_group.rds.id]
  storage_encrypted                       = true
  kms_key_id                              = data.aws_kms_key.key.arn
  skip_final_snapshot                     = true

  tags                                    = merge (local.common_tags, { Name = "${var.env}-rds-cluster" } )

}


