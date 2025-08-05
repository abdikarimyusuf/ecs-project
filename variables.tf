variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "my-app"
}
variable "container_port" {
  description = "Port your container listens on"
  type        = number
  default     = 80
}