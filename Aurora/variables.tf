variable "db_subnet_group" {
  description = "Value of the db subnet group name"
  type        = string
  default     = "rahul-tf-subnet-rds-group"
}

variable "tag" {
  description = "Value of the tag for the EC2 instance"
  type        = string
  default     = "Rahul-tf-PritunlVPN"
}

variable "cluster_identifier" {
  description = "Value of the cluster identifier for RDS Cluster"
  type        = string
  default     = "rahul-tf-aurora-cluster"
}

variable "db_name" {
  description = "Value of the initial db name for the Aurora"
  type        = string
  default     = "rahul"
}

variable "master_username" {
  description = "Value of the master username for the Aurora"
  type        = string
  default     = "rahul"
}

variable "master_password" {
  description = "Value of the master password for the Aurora"
  type        = string
  default     = "rahulrds"
  sensitive   = true
}
