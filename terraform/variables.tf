variable "ssh_public_key" {
  description = "The public SSH key to use for the EC2 instance."
  type        = string
}

variable "instance_type" {
  default = "t3.medium"
}
