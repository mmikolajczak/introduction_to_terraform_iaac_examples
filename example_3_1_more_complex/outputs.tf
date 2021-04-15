output "daily_cat_api_gw_endpoint_invoke_url" {
  value = "${aws_api_gateway_deployment.daily_cat_api.invoke_url}${aws_api_gateway_stage.alpha.stage_name}${aws_api_gateway_resource.daily_cat.path}"
}
