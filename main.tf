terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # profile = "mck-sandbox"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

module "instance_key_pair" {
  source = "github.com/TH-Logistic/key_pair"

  key_pair_name = var.tenant_unique_id
}

module "vpc" {
  source = "github.com/TH-Logistic/vpc"
}
module "internet_gateway" {
  source = "github.com/TH-Logistic/gateway"

  vpc_id = module.vpc.vpc_id
}

# module "instance_rds" {
#   source = "github.com/thinhlh/terraform-rds"

#   vpc_id              = module.vpc.vpc_id
#   subnet_cidr_1       = "10.0.10.0/24"
#   subnet_cidr_2       = "10.0.20.0/24"
#   internet_gateway_id = module.internet_gateway.internet_gateway_id
#   engine              = "postgres"
#   rds_db_name         = var.rds_db_name
#   rds_username        = var.rds_username
#   rds_password        = var.rds_password
#   allocated_storage   = 10
# }

# data "template_file" "job_script" {
#   template = file("./scripts/instance-user-data/job-service.tftpl")
#   vars = {
#     postgres_host     = "module.instance_rds.rds_ip"
#     postgres_port     = module.instance_rds.rds_port
#     postgres_db       = var.rds_db_name
#     postgres_user     = var.rds_username
#     postgres_password = var.rds_password

#     domain_url = "localhost"
#   }

#   depends_on = [module.instance_rds]
# }

# data "template_file" "billing_script" {
#   template = file("./scripts/instance-user-data/billing-service.tftpl")
#   vars = {
#     postgres_host     = "module.instance_rds.rds_ip"
#     postgres_port     = module.instance_rds.rds_port
#     postgres_db       = var.rds_db_name
#     postgres_user     = var.rds_username
#     postgres_password = var.rds_password

#     domain_url = "localhost"
#   }

#   depends_on = [module.instance_rds]
# }

data "template_cloudinit_config" "service_template_file" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = file("./scripts/ec2-user-data-ubuntu.sh")
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/mongo-db.tftpl", {
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/postgres-db.tftpl", {
      postgres_db       = var.rds_db_name
      postgres_user     = var.rds_username
      postgres_password = var.rds_password
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/auth-service.tftpl", {
      algorithm      = "HS256"
      secret_key     = var.app_secret
      mongo_host     = "mongo_container"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/product-service.tftpl", {
      mongo_host     = "mongo_container"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password

      domain_url = "localhost"
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/transportation-service.tftpl", {
      mongo_host     = "mongo_container"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password

      domain_url         = "localhost"
      google_map_api_key = "AIzaSyDEokOCthVrnmMPiI_fLEZKQtV1SjFvjxQ"
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/organization-service.tftpl", {
      mongo_host     = "mongo_container"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password

      domain_url = "localhost"
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/route-service.tftpl", {
      mongo_host     = "mongo_container"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password

      domain_url         = "localhost"
      google_map_api_key = "AIzaSyDEokOCthVrnmMPiI_fLEZKQtV1SjFvjxQ"
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/healthcheck-service.tftpl", {
      mongo_host     = "mongo_container"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password

      domain_url = "localhost"
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/job-service.tftpl", {
      postgres_host     = "postgres_container"
      postgres_port     = 5432
      postgres_db       = var.rds_db_name
      postgres_user     = var.rds_username
      postgres_password = var.rds_password

      domain_url = "localhost"
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/billing-service.tftpl", {
      postgres_host     = "postgres_container"
      postgres_port     = 5432
      postgres_db       = var.rds_db_name
      postgres_user     = var.rds_username
      postgres_password = var.rds_password

      domain_url = "localhost"
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/user-service.tftpl", {
      mongo_host     = "mongo_container"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password
      auth_host      = "localhost"
      auth_port      = 8001
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/mail-service.tftpl", {
      mongo_host     = "mongo_container"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password

      domain_url = "localhost"
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/gateway.tftpl", {
      auth_host           = "localhost"
      product_host        = "localhost"
      transportation_host = "localhost"
      garage_host         = "localhost"
      organization_host   = "localhost"
      route_host          = "localhost"
      location_host       = "localhost"
      healthcheck_host    = "localhost"
      job_host            = "localhost"
      billing_host        = "localhost"
      user_host           = "localhost"
      mail_host           = "localhost"
    })
  }
}

module "instance_server" {
  source = "github.com/TH-Logistic/ec2"

  key_pair_name        = module.instance_key_pair.key_pair_name
  internet_gateway_id  = module.internet_gateway.internet_gateway_id
  vpc_id               = module.vpc.vpc_id
  instance_type        = "t3.xlarge"
  subnet_cidr          = "10.0.0.0/24"
  use_user_data_base64 = true
  instance_name        = "${var.tenant_unique_id}-server"
  user_data_base64     = data.template_cloudinit_config.service_template_file.rendered
}

data "template_cloudinit_config" "frontend_template_file" {

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = file("./scripts/ec2-user-data-ubuntu.sh")
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/web-admin.tftpl", {
      backend_url = "${module.instance_server.public_ip}:9000"
    })
  }
}

module "instance_frontend" {
  source = "github.com/TH-Logistic/ec2"

  key_pair_name        = module.instance_key_pair.key_pair_name
  internet_gateway_id  = module.internet_gateway.internet_gateway_id
  vpc_id               = module.vpc.vpc_id
  instance_type        = "t3.xlarge"
  subnet_cidr          = "10.0.10.0/24"
  use_user_data_base64 = true
  instance_name        = "${var.tenant_unique_id}-frontend"
  user_data_base64     = data.template_cloudinit_config.frontend_template_file.rendered
  depends_on = [ module.instance_server, data.template_cloudinit_config.frontend_template_file ]
}