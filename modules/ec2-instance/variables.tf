variable "ami" {
  type        = string
  description = "AMI ID to use for the instances"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs"
}

variable "instance_count" {
  type        = number
  default     = 2
}

variable "name_prefix" {
  type        = string
  default     = "ec2"
}
