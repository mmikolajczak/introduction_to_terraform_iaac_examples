output "daily_cat_api_gw_endpoint_invoke_url" {
  value = "${aws_api_gateway_deployment.daily_cat_api.invoke_url}${aws_api_gateway_stage.alpha.stage_name}${aws_api_gateway_resource.daily_cat.path}"
}

output "daily_cat_sampling_statistics_table_name" {
  value = aws_dynamodb_table.daily_cat_photos_sampling_statistics.name
}
