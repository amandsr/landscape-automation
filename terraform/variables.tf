variable "key_name" {
  description = "SSH key pair name"
}

variable "public_key_path" {
  description = "Path to your public key"
  default = "~/.ssh/id_rsa.pub"
}

variable "instance_type" {
  default = "t3.medium"
}
