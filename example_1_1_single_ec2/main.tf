provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example_vm" {
  ami = "ami-09135e71dc2619458"  # Ubuntu 18.04
  instance_type = "t2.micro"
}
