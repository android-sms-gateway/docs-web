variable "swarm-manager-host" {
  type        = string
  sensitive   = true
  description = "Address of swarm manager"
}

variable "app-name" {
  type        = string
  description = "Name of app"
}

variable "app-version" {
  type        = string
  description = "Version of Docker image of app"
  default     = "1.0"
}

variable "app-host" {
  type        = string
  description = "Hostname of app"
}

variable "memory-limit" {
  type        = number
  description = "Memory limit in bytes"
  default     = 16 * 1024 * 1024
}

