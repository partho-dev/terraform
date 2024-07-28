variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = list(string)
}

variable "pub_sub" {
  type = list(string)
}

variable "priv_sub" {
  type = list(string)
}