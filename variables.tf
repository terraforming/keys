variable "admin_password" {
  description = "Windows Adminin password"
  default = "1qaz2wsx"
}
variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default = "terraform"
}

variable "key_path" {
  description = "Path to the private portion of the SSH key specified."
  default = "terraform.pem"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-west-2"
}

# Ubuntu Precise 12.04 LTS (x64)
variable "aws_amis" {
  default = {
    us-west-1 = "ami-5189a661"
  }
}

variable "access_key" {
	default = "AKIBAICVZCSM2AEMIGNZQ"
}

variable "secret_key" {
	default = "cx8//zBy8vCVepzKQUekJ2Tu2h6wlkIIY5zkp2YiE"

}