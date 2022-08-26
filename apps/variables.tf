
variable "project_name" {
  default = "with-s3-1"
}

variable "region" {
  default = "eu-west-1"
}


variable "desired_count" {
  default = 2
}

variable "ecr_image" {
  type = string
}
