resource "aws_api_gateway_rest_api" "daily_cat_api" {
  name = "daily_cat_api"

  endpoint_configuration {
    types = ["REGIONAL"]  # Might eventually consider changing it to EDGE.
  }

  binary_media_types = ["*/*"]
}

resource "aws_api_gateway_deployment" "daily_cat_api" {
  rest_api_id = aws_api_gateway_rest_api.daily_cat_api.id

  triggers = {
    # The configuration below calculates hash of the current file on the fly, causing any
    # changes/differences in it to trigger redeployment.
    # Note that the assumption is that all resources connected to this API are present in
    # this particular file.
    # Update: unfortunately, it seems that depends on all/most endpoints might be needed
    # after all – investigate this inconvenience later.
    redeployment = sha1(jsonencode(filesha1("${path.module}/api_gw.tf")))
  }

  lifecycle {
    create_before_destroy = true
  }

  # Note: should depend on all resources/methods/integrations defined in API – otherwise will try to create
  # deployment before they are are ready/prepared (as integrations require resource/method, they should suffice in
  # depends_on list).
  depends_on = [
    aws_api_gateway_integration.daily_cat_get_lambda_handler
  ]
}

resource "aws_api_gateway_stage" "alpha" {
  deployment_id = aws_api_gateway_deployment.daily_cat_api.id
  rest_api_id   = aws_api_gateway_rest_api.daily_cat_api.id
  stage_name    = "alpha"
}

resource "aws_api_gateway_resource" "daily_cat" {
  parent_id   = aws_api_gateway_rest_api.daily_cat_api.root_resource_id
  path_part   = "daily_cat"
  rest_api_id = aws_api_gateway_rest_api.daily_cat_api.id
}

resource "aws_api_gateway_method" "daily_cat_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.daily_cat.id
  rest_api_id   = aws_api_gateway_rest_api.daily_cat_api.id
}

resource "aws_api_gateway_integration" "daily_cat_get_lambda_handler" {
  rest_api_id = aws_api_gateway_rest_api.daily_cat_api.id
  resource_id = aws_api_gateway_resource.daily_cat.id
  http_method = aws_api_gateway_method.daily_cat_get.http_method
  integration_http_method = "POST"  # "Not all methods are compatible with all AWS integrations. e.g. Lambda function can only be invoked via POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.daily_cat_endpoint.invoke_arn
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "allow_daily_cat_endpoint_lambda_execution_from_api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.daily_cat_endpoint.function_name
  principal     = "apigateway.amazonaws.com"

  # http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
//  source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.daily_cat_api.id}/*/${aws_api_gateway_method.daily_cat_get.http_method}${aws_api_gateway_resource.daily_cat.path}"
}
