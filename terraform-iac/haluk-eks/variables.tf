variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "AWS profile"
  type        = string
  default     = "default"
}

variable "eks_name" {
  description = "AWS eks_name"
  type        = string
  default     = "test"
}

variable "eks_version" {
  description = "EKS version"
  type        = string
  default     = "1.31"
}

variable "machine_type" {
  description = "AWS machine_type"
  type        = string
  default     = "t3.medium"
}