variable "env" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "env must be either 'dev' or 'prod'."
  }
}

variable "name_prefix" {
  description = "Short prefix used to build every resource name"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{1,12}$", var.name_prefix))
    error_message = "name_prefix must be lowercase letters, digits and hyphens, up to 12 characters."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to deploy for all three services"
  type        = string
}

variable "option_a" {
  description = "First voting option shown on the vote page"
  type        = string
  default     = "ביבי"
}

variable "option_b" {
  description = "Second voting option shown on the vote page"
  type        = string
  default     = "אייזנקוט"
}
