variable "aws_region" {
  description = "AWS region for deployment"
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}

variable "key_name" {
  description = "Name of an existing AWS KeyPair to enable SSH access to the instances"
  type        = string
}

variable "instance_type_gateway" {
  description = "Instance type for the API Gateway (iii engine)"
  default     = "t2.micro"
}

variable "instance_type_caller" {
  description = "Instance type for the TypeScript caller worker"
  default     = "t2.medium"
}

variable "instance_type_inference" {
  description = "Instance type for the Python inference worker (needs more memory/CPU for model loading)"
  default     = "t2.large"
}

variable "repository_url" {
  description = "The public Git repository URL."
  type        = string
  default     = "https://github.com/khxtrikk/alchemyst.git"
}
