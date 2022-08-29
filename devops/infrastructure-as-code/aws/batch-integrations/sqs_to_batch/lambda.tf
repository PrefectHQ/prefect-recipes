# resource "aws_lambda_permission" "LambdaPermission2" {
#     action = "lambda:InvokeFunction"
#     function_name = "${aws_lambda_function.LambdaFunction2.arn}"
#     principal = "apigateway.amazonaws.com"
#     source_arn = "arn:aws:execute-api:us-east-1:330830921905:gscx3uncki/*"
# }

# resource "aws_lambda_permission" "LambdaPermission3" {
#     action = "lambda:InvokeFunction"
#     function_name = "${aws_lambda_function.LambdaFunction2.arn}"
#     principal = "apigateway.amazonaws.com"
#     source_arn = "arn:aws:execute-api:us-east-1:330830921905:q3yrw5zyvl/*"
# }