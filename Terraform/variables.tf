variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "igw_name" {
  description = "The name of the Internet Gateway"
  type        = string
}

variable "rt_name" {
  description = "The name of the Route Table"
  type        = string
}

variable "subnet_name" {
  description = "The name of the Public Subnet"
  type        = string
}

variable "private_subnet_name" {
  description = "The name of the Private Subnet"
  type        = string
}

variable "sg_name" {
  description = "The name of the Security Group"
  type        = string
}

variable "rds_sg_name" {
  description = "The name of the RDS Security Group"
  type        = string
}

variable "instance_name" {
  description = "The name of the EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "iam_role" {
  description = "IAM role name"
  type        = string
}



variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.large"
}

variable "volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 64
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password
