output "hello_world_url" {
  value = "http://${aws_instance.example_http_server.public_ip}:${var.server_port}"
}
