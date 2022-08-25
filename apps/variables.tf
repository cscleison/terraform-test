
variable "project_name" {
  default = "demo-1"
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
