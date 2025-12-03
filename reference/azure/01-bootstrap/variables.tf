variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "gitops-lab"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    environment = "lab"
    project     = "gitops-learning"
  }
}
