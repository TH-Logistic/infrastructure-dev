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

  key_pair_name = var.key_pair_name
}

module "vpc" {
  source = "github.com/TH-Logistic/vpc"
}
module "internet_gateway" {
  source = "github.com/TH-Logistic/gateway"

  vpc_id = module.vpc.vpc_id
}

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
    content = templatefile("./scripts/instance-user-data/product-service.tftpl", {
      mongo_host     = "localhost"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/route-service.tftpl", {
      mongo_host     = "localhost"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/auth-service.tftpl", {
      algorithm      = "HS256"
      secret_key     = var.app_secret
      mongo_host     = "localhost"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/transportation-service.tftpl", {
      mongo_host     = "localhost"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/organization-service.tftpl", {
      mongo_host     = "localhost"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/route-service.tftpl", {
      mongo_host     = "localhost"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/healthcheck-service.tftpl", {
      mongo_host     = "localhost"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/billing-service.tftpl", {
      mongo_host     = "localhost"
      mongo_port     = 27017
      mongo_db_name  = var.mongo_db_name
      mongo_username = var.mongo_username
      mongo_password = var.mongo_password
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/user-service.tftpl", {
      mongo_host     = "localhost"
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
    content = templatefile("./scripts/instance-user-data/gateway.tftpl", {
      product_host        = "localhost"
      transportation_host = "localhost"
      garage_host         = "localhost"
      organization_host   = "localhost"
      route_host          = "localhost"
      location_host       = "localhost"
      healthcheck_host    = "localhost"
      job_host            = "localhost"
      billing_host        = "localhost"
      auth_host           = "localhost"
      user_host           = "localhost"
    })
  }
}

module "instance_server" {
  source = "github.com/TH-Logistic/ec2"

  key_pair_name       = module.instance_key_pair.key_pair_name
  instance_name       = "th-server"
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  vpc_id              = module.vpc.vpc_id
  instance_type       = "t3.xlarge"
  subnet_cidr         = "10.0.0.0/24"
  user_data = templatefile("./scripts/instance-user-data/mongo-db.tftpl", {
    mongo_db_name  = var.mongo_db_name
    mongo_username = var.mongo_username
    mongo_password = var.mongo_password
  })
}