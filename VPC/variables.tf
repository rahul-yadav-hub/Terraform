variable "vpc_name" {
  description = "Value of the vpc name"
  type        = string
  default     = "Custom-VPC"
}

variable "cidr_block_vpc" {
  description = "Value of the CIDR Block in VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tag_name" {
  description = "Tag all resource with this value"
  type        = string
  default     = "Rahul-tf"
}
