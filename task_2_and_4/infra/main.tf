############################ Task 2 ############################
terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
  }

  backend "s3" {
    bucket = "pgr301-2024-terraform-state"
    key    = "19/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

# SQS Queue with specific timeout for Lambda processing
resource "aws_sqs_queue" "image_queue" {
  name                       = "image-generation-queue-19"
  visibility_timeout_seconds = 70  # Slightly longer than Lambda timeout
  message_retention_seconds  = 1209600  # 14 days
  receive_wait_time_seconds  = 20  # Enable long polling
}

# Base Lambda role
resource "aws_iam_role" "lambda_role" {
  name = "image_processor_lambda_role_19"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# CloudWatch Logs policy
resource "aws_iam_role_policy" "lambda_logs" {
  name = "lambda_cloudwatch_logs_19"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:eu-west-1:*:log-group:/aws/lambda/image-processor-19:*"
        ]
      }
    ]
  })
}

# SQS specific policy
resource "aws_iam_role_policy" "lambda_sqs" {
  name = "lambda_sqs_19"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [aws_sqs_queue.image_queue.arn]
      }
    ]
  })
}

# S3 specific policy
resource "aws_iam_role_policy" "lambda_s3" {
  name = "lambda_s3_19"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:PutObject"]
        Resource = ["arn:aws:s3:::pgr301-couch-explorers/19/*"]
      }
    ]
  })
}

# Bedrock specific policy
resource "aws_iam_role_policy" "lambda_bedrock" {
  name = "lambda_bedrock_19"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["bedrock:InvokeModel"]
        Resource = ["arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"]
      }
    ]
  })
}

# Lambda function
resource "aws_lambda_function" "image_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "image-processor-19"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_sqs.lambda_handler"
  runtime         = "python3.11"
  timeout         = 60
  memory_size     = 256

  environment {
    variables = {
      BUCKET_NAME = "pgr301-couch-explorers"
    }
  }

  # Add tracing config if needed
  tracing_config {
    mode = "Active"
  }
}

# Lambda trigger for SQS with specific batch size
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn        = aws_sqs_queue.image_queue.arn
  function_name          = aws_lambda_function.image_processor.arn
  batch_size            = 1
}

# Lambda function code with dependencies
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source_dir  = "."
  excludes    = ["*.tf", "*.zip", ".terraform", ".terraform.lock.hcl"]
}

output "sqs_queue_url" {
  value = aws_sqs_queue.image_queue.url
  description = "URL of the SQS queue for image processing"
}

output "lambda_function_name" {
  value = aws_lambda_function.image_processor.function_name
  description = "Name of the Lambda function"
}
