variable "function_name" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "handler" {
  type = string
}

variable "source_file" {
  type = string
}

variable "output_zip" {
  type = string
}

variable "bucket_arn" {
  type = string
}