

variable "private_subnets" {
  type = list(object({
    cidr_block = string
    region     = string
  }))
}

variable "public_subnets" {
  type = list(object({
    cidr_block = string
    region     = string
  }))
}