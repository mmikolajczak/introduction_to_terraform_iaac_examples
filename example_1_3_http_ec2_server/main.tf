provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example_http_server" {
  ami = "ami-09135e71dc2619458"  # Ubuntu 18.04
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.allow_tcp_server_port_in_traffic.id]

  user_data = <<-EOF
              #!bin/bash
              echo "Sprzedam Opla" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  tags = {
    Name = "simple-http-server"
  }
}

resource "aws_security_group" "allow_tcp_server_port_in_traffic" {
  name = "allow_tcp_server_port_in_traffic"

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = var.server_port
    to_port = var.server_port
  }
}
