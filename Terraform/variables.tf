variable "aws_region" {
  type = string
}

variable "env" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "pub_subnet_count" {
  type = number
}

variable "pub_cidr_block" {
  type = list(string)
}

variable "pub_availability_zone" {
  type = list(string)
}

variable "ec2_instance_count" {
  type = number
}

variable "ec2_instance_type" {
  type = string
}

variable "ec2_volume_size" {
  type = number
}

variable "ec2_volume_type" {
  type = string
}
