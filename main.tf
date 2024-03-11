terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}

provider "aws" {
  region  = "ca-central-1"
  profile = "default"
}

# IAM Role Creation
resource "aws_iam_role" "iam_role" {
  name               = "lab6-iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Policy Creation
resource "aws_iam_policy" "iam_policy" {
  name        = "lab6-iam_policy"
  description = "Example policy for AWS resources"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "s3:List*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

# AWS Resources 
resource "aws_instance" "ec2_instance" {
  ami           = "ami-0639d0300c73bb369"
  instance_type = "t2.micro"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket_prefix = "demo-bucket-safal1"
}

# Disassociate IAM policy from IAM role
resource "aws_iam_role_policy_attachment" "detach_policy" {
  role       =aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn

  lifecycle {
    ignore_changes = [
      policy_arn
    ]
    prevent_destroy = false
  }
}

# Remove Role
resource "aws_iam_role_policy_attachment" "remove_role" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn

  lifecycle {
    ignore_changes = [
      role,
    ]
  }
}