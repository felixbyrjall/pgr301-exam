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

# Variables
variable "notification_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
}

# SQS Queue
resource "aws_sqs_queue" "image_queue" {
  name                       = "image-generation-queue-19"
  visibility_timeout_seconds = 70
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 20
}

# Base Lambda role
resource "aws_iam_role" "lambda_role" {
  name = "image_processor_lambda_role_19"

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
  name = "lambda_logs_policy_19"
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
        Resource = ["arn:aws:logs:eu-west-1:*:log-group:/aws/lambda/image-processor-19:*"]
      }
    ]
  })
}

# SQS policy
resource "aws_iam_role_policy" "lambda_sqs" {
  name = "lambda_sqs_policy_19"
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

# S3 policy
resource "aws_iam_role_policy" "lambda_s3" {
  name = "lambda_s3_policy_19"
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

# Bedrock policy
resource "aws_iam_role_policy" "lambda_bedrock" {
  name = "lambda_bedrock_policy_19"
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

  environment {
    variables = {
      BUCKET_NAME = "pgr301-couch-explorers"
    }
  }
}

# Lambda trigger for SQS
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.image_queue.arn
  function_name    = aws_lambda_function.image_processor.arn
  batch_size       = 1
}

# Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source_file = "${path.module}/lambda_sqs.py"
}

# SNS Topic for alerts
resource "aws_sns_topic" "sqs_alarm_topic" {
  name = "sqs-alarm-topic"
}

resource "aws_sns_topic_subscription" "sqs_alarm_email_subscription" {
  topic_arn = aws_sns_topic.sqs_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "sqs_oldest_message_age" {
  alarm_name          = "SQS-OldestMessageAge-Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 10  # 10 seconds
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60
  statistic          = "Maximum"
  dimensions = {
    QueueName = aws_sqs_queue.image_queue.name
  }
  alarm_actions = [aws_sns_topic.sqs_alarm_topic.arn]
}

# Output URL
output "sqs_queue_url" {
  value = aws_sqs_queue.image_queue.url
  description = "URL of the SQS queue for image processing"
}
