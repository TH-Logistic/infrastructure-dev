variable "tenant_unique_id" {
  description = "Tenant Unique Identifier"
  type        = string
  default     = "thlogistic"
}
variable "aws_region" {
  description = "AWS default region"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "aws_session_token" {
  description = "AWS session token"
  type        = string
}

variable "key_pair_name" {
  description = "Key pair name for instances"
  type        = string
}

variable "mongo_db_name" {
  description = "mongo database name"
  type        = string
}

variable "mongo_username" {
  description = "mongo database username"
  type        = string
}

variable "mongo_password" {
  description = "mongo database password"
  type        = string
}

variable "app_secret" {
  description = "app_secret"
  type        = string
}

variable "rds_db_name" {
  description = "Postgres database name"
  type        = string
}

variable "rds_username" {
  description = "Postgres username"
  type        = string
}

variable "rds_password" {
  description = "Postgres password"
  type        = string
}