variable "name" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "image" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "execution_role_arn" {
  type = string
}

variable "environment" {
  type    = map(string)
  default = {}
}

variable "secrets" {
  type    = map(string)
  default = {}
}

variable "container_port" {
  type    = number
  default = null
}

variable "target_group_arn" {
  type    = string
  default = null
}

variable "desired_count" {
  type    = number
  default = 1
}