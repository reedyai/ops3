variable "ami_id" {
  description = "AMI ID for the EC2 instance (Ubuntu)"
  type        = string
  default     = "ami-091138d0f0d41ff90"
}

variable "instance_type" {
  description = "EC2 instance type (medium for more RAM)"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}