#Variables Definition
variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "execution_role_arn" {
  description = "ARN for the execution role"
  default = "arn:aws:iam::905418190155:role/ecsTaskExecutionRole"
}

variable "vpc_cidr" {
	default = "10.0.0.0/16"
}


variable "subnet_cidr" {
	default = "10.0.1.0/24"
}


variable "http_port" {
	default = 80
}

variable "sg_cidr" {
	default = "0.0.0.0/0"
}

variable "s3_bucket" {
    default = "mybucket-vk-remote-state"
}