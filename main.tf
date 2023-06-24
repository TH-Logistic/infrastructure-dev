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

module "instance_rds" {
  source = "github.com/thinhlh/terraform-rds"

  vpc_id              = module.vpc.vpc_id
  subnet_cidr_1       = "10.0.10.0/24"
  subnet_cidr_2       = "10.0.20.0/24"
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  engine              = "postgres"
  rds_db_name         = var.rds_db_name
  rds_username        = var.rds_username
  rds_password        = var.rds_password
  allocated_storage   = 10
}

data "template_cloudinit_config" "service_template_file" {
  depends_on = [ module.instance_rds ]
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
    content = templatefile("./scripts/instance-user-data/product-service.tftpl", {
      mongo_host     = "localhost"
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
      mongo_host     = "localhost"
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
      mongo_host     = "localhost"
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
      mongo_host     = "localhost"
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
      mongo_host     = "localhost"
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
      postgres_host     = module.instance_rds.rds_ip
      postgres_port     = module.instance_rds.rds_port
      postgres_db       = var.rds_db_name
      postgres_user     = var.rds_username
      postgres_password = var.rds_password

      domain_url = "localhost"
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/instance-user-data/billing-service.tftpl", {
      postgres_host     = module.instance_rds.rds_ip
      postgres_port     = module.instance_rds.rds_port
      postgres_db       = var.rds_db_name
      postgres_user     = var.rds_username
      postgres_password = var.rds_password

      domain_url = "localhost"
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
    content = templatefile("./scripts/instance-user-data/mail-service.tftpl", {
      mongo_host     = "localhost"
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

  key_pair_name       = module.instance_key_pair.key_pair_name
  instance_name       = var.tenant_unique_id
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  vpc_id              = module.vpc.vpc_id
  instance_type       = "t3.xlarge"
  subnet_cidr         = "10.0.0.0/24"
  use_user_data_base64 = true
  user_data_base64 = data.template_cloudinit_config.service_template_file.rendered
}

# resource "aws_ec2_instance_state" "instance_server_state"{
#   instance_id = module.instance_server.instance_id
#   state       = "stopped"
# }

# resource "aws_ses_email_identity" "root_email" {
#   email = "thinhlh0812@gmail.com"
# }

# resource "aws_ses_email_identity" "sub_email" {
#   email = "19520285@gm.uit.edu.vn"
# }

# resource "aws_ses_template" "ForgetPasswordTemplate" {
#   name    = "ForgetPasswordTemplate"
#   subject = "[IMPORTANT] You password has been reset for TH Logistic"
#   html    = <<-EOT
#   <body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #f2f3f8;" leftmargin="0">
#     <!--100% body table-->
#     <table cellspacing="0" border="0" cellpadding="0" width="100%" bgcolor="#f2f3f8"
#         style="@import url(https://fonts.googleapis.com/css?family=Rubik:300,400,500,700|Open+Sans:300,400,600,700); font-family: 'Open Sans', sans-serif;">
#         <tr>
#             <td>
#                 <table style="background-color: #f2f3f8; max-width:670px;  margin:0 auto;" width="100%" border="0"
#                     align="center" cellpadding="0" cellspacing="0">
#                     <tr>
#                         <td style="height:80px;">&nbsp;</td>
#                     </tr>
#                     <tr>
#                         <td style="text-align:center;">
#                           <a href="https://github.com/thinhlh" title="logo" target="_blank">
#                             <img width="100" src="https://avatars.githubusercontent.com/u/128272091?s=400&u=0a0976f7ea16a6dc3ba70e8cf2a3dc540a5e75a4&v=4" title="logo" alt="logo">
#                           </a>
#                         </td>
#                     </tr>
#                     <tr>
#                         <td style="height:20px;">&nbsp;</td>
#                     </tr>
#                     <tr>
#                         <td>
#                             <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0"
#                                 style="max-width:670px;background:#fff; border-radius:3px; text-align:center;-webkit-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);-moz-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);box-shadow:0 6px 18px 0 rgba(0,0,0,.06);">
#                                 <tr>
#                                     <td style="height:40px;">&nbsp;</td>
#                                 </tr>
#                                 <tr>
#                                     <td style="padding:0 35px;">
#                                         <h1 style="color:#1e1e2d; font-weight:500; margin:0;font-size:32px;font-family:'Rubik',sans-serif;">You have
#                                             requested to reset your password</h1>
#                                         <span
#                                             style="display:inline-block; vertical-align:middle; margin:29px 0 26px; border-bottom:1px solid #cecece; width:100px;"></span>
#                                         <p style="color:#455056; font-size:15px;line-height:24px; margin:0;">
#                                             We cannot simply send you your old password for your account with email: {{email}}. Hence, we send you your new password, use this password to access your account. You can change your password for further security.
#                                         </p>
#                                         <a href="javascript:void(0);"
#                                             style="background:#75CCD0;text-decoration:none !important; font-weight:500; margin-top:35px; color:#1e1e2d; font-size:14px;padding:10px 24px;display:inline-block;border-radius:50px;">{{newPassword}}</a>
#                                     </td>
#                                 </tr>
#                                 <tr>
#                                     <td style="height:40px;">&nbsp;</td>
#                                 </tr>
#                             </table>
#                         </td>
#                     <tr>
#                         <td style="height:20px;">&nbsp;</td>
#                     </tr>
#                     <tr>
#                         <td style="text-align:center;">
#                             <p style="font-size:14px; color:rgba(69, 80, 86, 0.7411764705882353); line-height:18px; margin:0 0 0;">&copy; <strong>www.thinhlh.com</strong></p>
#                         </td>
#                     </tr>
#                     <tr>
#                         <td style="height:80px;">&nbsp;</td>
#                     </tr>
#                 </table>
#             </td>
#         </tr>
#     </table>
#     <!--/100% body table-->
#   </body>
#   EOT
# }

# resource "aws_ses_template" "AccountActivatedTemplate" {
#   name    = "AccountActivatedTemplate"
#   subject = "THLogistic, Your account has been activated!"
#   html    = <<-EOT

#   <body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #f2f3f8;" leftmargin="0">
#     <!--100% body table-->
#     <table cellspacing="0" border="0" cellpadding="0" width="100%" bgcolor="#f2f3f8"
#         style="@import url(https://fonts.googleapis.com/css?family=Rubik:300,400,500,700|Open+Sans:300,400,600,700); font-family: 'Open Sans', sans-serif;">
#         <tr>
#             <td>
#                 <table style="background-color: #f2f3f8; max-width:670px;  margin:0 auto;" width="100%" border="0"
#                     align="center" cellpadding="0" cellspacing="0">
#                     <tr>
#                         <td style="height:80px;">&nbsp;</td>
#                     </tr>
#                     <tr>
#                         <td style="text-align:center;">
#                           <a href="https://github.com/thinhlh" title="logo" target="_blank">
#                             <img width="100" src="https://avatars.githubusercontent.com/u/128272091?s=400&u=0a0976f7ea16a6dc3ba70e8cf2a3dc540a5e75a4&v=4" title="logo" alt="logo">
#                           </a>
#                         </td>
#                     </tr>
#                     <tr>
#                         <td style="height:20px;">&nbsp;</td>
#                     </tr>
#                     <tr>
#                         <td>
#                             <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0"
#                                 style="max-width:670px;background:#fff; border-radius:3px; text-align:center;-webkit-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);-moz-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);box-shadow:0 6px 18px 0 rgba(0,0,0,.06);">
#                                 <tr>
#                                     <td style="height:40px;">&nbsp;</td>
#                                 </tr>
#                                 <tr>
#                                     <td style="padding:0 35px;">
#                                         <h1 style="color:#1e1e2d; font-weight:500; margin:0;font-size:32px;font-family:'Rubik',sans-serif;">
#                                           Welcome to TH Logistic, {{name}}
#                                         </h1>
#                                         <span
#                                             style="display:inline-block; vertical-align:middle; margin:29px 0 26px; border-bottom:1px solid #cecece; width:100px;"></span>
#                                         <p style="color:#455056; font-size:15px;line-height:24px; margin:0;">
#                                             We are delighted to see you here. It is our pleasure to announe that your account has been activated. You can use your email {{email}} and password created to access to our sites and start creating values from today!
#                                         </p>
#                                         <a href="mailto:thinhlh0812@gmail.com"
#                                             style="background:#75CCD0;text-decoration:none !important; font-weight:500; margin-top:35px; color:#1e1e2d; font-size:14px;padding:10px 24px;display:inline-block;border-radius:50px;">Visit our site</a>
#                                     </td>
#                                 </tr>
#                                 <tr>
#                                     <td style="height:40px;">&nbsp;</td>
#                                 </tr>
#                             </table>
#                         </td>
#                     <tr>
#                         <td style="height:20px;">&nbsp;</td>
#                     </tr>
#                     <tr>
#                         <td style="text-align:center;">
#                             <p style="font-size:14px; color:rgba(69, 80, 86, 0.7411764705882353); line-height:18px; margin:0 0 0;">&copy; <strong>www.thinhlh.com</strong></p>
#                         </td>
#                     </tr>
#                     <tr>
#                         <td style="height:80px;">&nbsp;</td>
#                     </tr>
#                 </table>
#             </td>
#         </tr>
#     </table>
#     <!--/100% body table-->
#   </body>
#   EOT
# }

# resource "aws_ses_template" "AccountSuspendTemplate" {
#   name    = "AccountSuspendTemplate"
#   subject = "THLogistic, Your account has been suspended!"
#   html    = <<-EOT
#   <body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #f2f3f8;" leftmargin="0">
#     <!--100% body table-->
#     <table cellspacing="0" border="0" cellpadding="0" width="100%" bgcolor="#f2f3f8"
#         style="@import url(https://fonts.googleapis.com/css?family=Rubik:300,400,500,700|Open+Sans:300,400,600,700); font-family: 'Open Sans', sans-serif;">
#         <tr>
#             <td>
#                 <table style="background-color: #f2f3f8; max-width:670px;  margin:0 auto;" width="100%" border="0"
#                     align="center" cellpadding="0" cellspacing="0">
#                     <tr>
#                         <td style="height:80px;">&nbsp;</td>
#                     </tr>
#                     <tr>
#                         <td style="text-align:center;">
#                           <a href="https://github.com/thinhlh" title="logo" target="_blank">
#                             <img width="100" src="https://avatars.githubusercontent.com/u/128272091?s=400&u=0a0976f7ea16a6dc3ba70e8cf2a3dc540a5e75a4&v=4" title="logo" alt="logo">
#                           </a>
#                         </td>
#                     </tr>
#                     <tr>
#                         <td style="height:20px;">&nbsp;</td>
#                     </tr>
#                     <tr>
#                         <td>
#                             <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0"
#                                 style="max-width:670px;background:#fff; border-radius:3px; text-align:center;-webkit-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);-moz-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);box-shadow:0 6px 18px 0 rgba(0,0,0,.06);">
#                                 <tr>
#                                     <td style="height:40px;">&nbsp;</td>
#                                 </tr>
#                                 <tr>
#                                     <td style="padding:0 35px;">
#                                         <h1 style="color:#1e1e2d; font-weight:500; margin:0;font-size:32px;font-family:'Rubik',sans-serif;">
#                                             Your account has been suspended, {{name}}
#                                         </h1>
#                                         <span
#                                             style="display:inline-block; vertical-align:middle; margin:29px 0 26px; border-bottom:1px solid #cecece; width:100px;"></span>
#                                         <p style="color:#455056; font-size:15px;line-height:24px; margin:0;">
#                                             Sorry for this action. Due to recent activites, your account have been suspended temporarily. Please contact supervisor to know more information or email us at <strong>support@www.thinhlh.com</strong> if this is unintended. Once again, sorry for this action, we always try our best to benefit you and others users.
#                                         </p>
#                                         <a href="https://www.thinhlh.com"
#                                             style="background:#75CCD0;text-decoration:none !important; font-weight:500; margin-top:35px; color:#1e1e2d; font-size:14px;padding:10px 24px;display:inline-block;border-radius:50px;">Contact supervisor</a>
#                                     </td>
#                                 </tr>
#                                 <tr>
#                                     <td style="height:40px;">&nbsp;</td>
#                                 </tr>
#                             </table>
#                         </td>
#                     <tr>
#                         <td style="height:20px;">&nbsp;</td>
#                     </tr>
#                     <tr>
#                         <td style="text-align:center;">
#                             <p style="font-size:14px; color:rgba(69, 80, 86, 0.7411764705882353); line-height:18px; margin:0 0 0;">&copy; <strong>www.thinhlh.com</strong></p>
#                         </td>
#                     </tr>
#                     <tr>
#                         <td style="height:80px;">&nbsp;</td>
#                     </tr>
#                 </table>
#             </td>
#         </tr>
#     </table>
#     <!--/100% body table-->
#   </body>
#   EOT
# }

# resource "aws_ses_template" "TenantActivatedTemplate" {
#   name    = "TenantActivatedTemplate"
#   subject = "THLogistic, Your organization has been activated!"
#   html    = <<-EOT
#   <body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #f2f3f8;" leftmargin="0">
#       <!--100% body table-->
#       <table cellspacing="0" border="0" cellpadding="0" width="100%" bgcolor="#f2f3f8"
#           style="@import url(https://fonts.googleapis.com/css?family=Rubik:300,400,500,700|Open+Sans:300,400,600,700); font-family: 'Open Sans', sans-serif;">
#           <tr>
#               <td>
#                   <table style="background-color: #f2f3f8; max-width:670px;  margin:0 auto;" width="100%" border="0"
#                       align="center" cellpadding="0" cellspacing="0">
#                       <tr>
#                           <td style="height:80px;">&nbsp;</td>
#                       </tr>
#                       <tr>
#                           <td style="text-align:center;">
#                             <a href="https://github.com/thinhlh" title="logo" target="_blank">
#                               <img width="100" src="https://avatars.githubusercontent.com/u/128272091?s=400&u=0a0976f7ea16a6dc3ba70e8cf2a3dc540a5e75a4&v=4" title="logo" alt="logo">
#                             </a>
#                           </td>
#                       </tr>
#                       <tr>
#                           <td style="height:20px;">&nbsp;</td>
#                       </tr>
#                       <tr>
#                           <td>
#                               <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0"
#                                   style="max-width:670px;background:#fff; border-radius:3px; text-align:center;-webkit-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);-moz-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);box-shadow:0 6px 18px 0 rgba(0,0,0,.06);">
#                                   <tr>
#                                       <td style="height:40px;">&nbsp;</td>
#                                   </tr>
#                                   <tr>
#                                       <td style="padding:0 35px;">
#                                           <h1 style="color:#1e1e2d; font-weight:500; margin:0;font-size:32px;font-family:'Rubik',sans-serif;">
#                                               Thank you for using our service, {{name}}
#                                           </h1>
#                                           <span
#                                               style="display:inline-block; vertical-align:middle; margin:29px 0 26px; border-bottom:1px solid #cecece; width:100px;"></span>
#                                           <p style="color:#455056; font-size:15px;line-height:24px; margin:0;">
#                                               It is our pleasure to have you joined and cooporated. Your service has been activated successfully. With {{package}} already registered, your organization are welcome to utilize services unlimitedly. Start your journey today! We hope you a great time.
#                                           </p>
#                                           <a href="https://www.thinhlh.com"
#                                               style="background:#75CCD0;text-decoration:none !important; font-weight:500; margin-top:35px; color:#1e1e2d; font-size:14px;padding:10px 24px;display:inline-block;border-radius:50px;">Visit our site</a>
#                                       </td>
#                                   </tr>
#                                   <tr>
#                                       <td style="height:40px;">&nbsp;</td>
#                                   </tr>
#                               </table>
#                           </td>
#                       <tr>
#                           <td style="height:20px;">&nbsp;</td>
#                       </tr>
#                       <tr>
#                           <td style="text-align:center;">
#                               <p style="font-size:14px; color:rgba(69, 80, 86, 0.7411764705882353); line-height:18px; margin:0 0 0;">&copy; <strong>www.thinhlh.com</strong></p>
#                           </td>
#                       </tr>
#                       <tr>
#                           <td style="height:80px;">&nbsp;</td>
#                       </tr>
#                   </table>
#               </td>
#           </tr>
#       </table>
#       <!--/100% body table-->
#   </body>
#   EOT
# }

# resource "aws_ses_template" "TenantSuspendedTemplate" {
#   name    = "TenantSuspendedTemplate"
#   subject = "THLogistic, Your organization has been suspended!"
#   html    = <<-EOT
#   <body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #f2f3f8;" leftmargin="0">
#     <!--100% body table-->
#     <table cellspacing="0" border="0" cellpadding="0" width="100%" bgcolor="#f2f3f8"
#         style="@import url(https://fonts.googleapis.com/css?family=Rubik:300,400,500,700|Open+Sans:300,400,600,700); font-family: 'Open Sans', sans-serif;">
#         <tr>
#             <td>
#                 <table style="background-color: #f2f3f8; max-width:670px;  margin:0 auto;" width="100%" border="0"
#                     align="center" cellpadding="0" cellspacing="0">
#                     <tr>
#                         <td style="height:80px;">&nbsp;</td>
#                     </tr>
#                     <tr>
#                         <td style="text-align:center;">
#                           <a href="https://github.com/thinhlh" title="logo" target="_blank">
#                             <img width="100" src="https://avatars.githubusercontent.com/u/128272091?s=400&u=0a0976f7ea16a6dc3ba70e8cf2a3dc540a5e75a4&v=4" title="logo" alt="logo">
#                           </a>
#                         </td>
#                     </tr>
#                     <tr>
#                         <td style="height:20px;">&nbsp;</td>
#                     </tr>
#                     <tr>
#                         <td>
#                             <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0"
#                                 style="max-width:670px;background:#fff; border-radius:3px; text-align:center;-webkit-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);-moz-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);box-shadow:0 6px 18px 0 rgba(0,0,0,.06);">
#                                 <tr>
#                                     <td style="height:40px;">&nbsp;</td>
#                                 </tr>
#                                 <tr>
#                                     <td style="padding:0 35px;">
#                                         <h1 style="color:#1e1e2d; font-weight:500; margin:0;font-size:32px;font-family:'Rubik',sans-serif;">
#                                             Your service has been suspended, {{name}}
#                                         </h1>
#                                         <span
#                                             style="display:inline-block; vertical-align:middle; margin:29px 0 26px; border-bottom:1px solid #cecece; width:100px;"></span>
#                                         <p style="color:#455056; font-size:15px;line-height:24px; margin:0;">
#                                             Due to recent activites with inactive papyment, your service have been suspended. If your organization have not yet complete billing payment, please take your time to complete it as soon as possible. Then please email us from the link below or to <strong>contact@www.thinhlh.com</strong>. Hope you have a great day.
#                                         </p>
#                                         <a href="mailto:thinhlh0812@gmail.com"
#                                             style="background:#75CCD0;text-decoration:none !important; font-weight:500; margin-top:35px; color:#1e1e2d; font-size:14px;padding:10px 24px;display:inline-block;border-radius:50px;">Contact supervisor</a>
#                                     </td>
#                                 </tr>
#                                 <tr>
#                                     <td style="height:40px;">&nbsp;</td>
#                                 </tr>
#                             </table>
#                         </td>
#                     <tr>
#                         <td style="height:20px;">&nbsp;</td>
#                     </tr>
#                     <tr>
#                         <td style="text-align:center;">
#                             <p style="font-size:14px; color:rgba(69, 80, 86, 0.7411764705882353); line-height:18px; margin:0 0 0;">&copy; <strong>www.thinhlh.com</strong></p>
#                         </td>
#                     </tr>
#                     <tr>
#                         <td style="height:80px;">&nbsp;</td>
#                     </tr>
#                 </table>
#             </td>
#         </tr>
#     </table>
#     <!--/100% body table-->
#   </body>
#   EOT
# }