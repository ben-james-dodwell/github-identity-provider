variable "bucket" {
  type    = string
  default = "terraform-state"
}

variable "key" {
  type    = string
  default = "terraform.tfstate"
}

variable "dynamodb_table" {
  type    = string
  default = "terraform-state"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "frontend_bucket" {
  type    = string
  default = "terraform-state"
}

variable "blog_bucket" {
  type    = string
  default = "terraform-state"
}