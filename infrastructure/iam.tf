# IAM user for GitHub Actions deploy workflow (least-privilege)

resource "aws_iam_user" "github_deploy" {
  name = "${var.project_name}-github-deploy"
  path = "/ci/"

  tags = merge(local.common_tags, {
    Purpose = "GitHub Actions deploy (S3 + CloudFront)"
  })
}

resource "aws_iam_user_policy" "github_deploy" {
  name = "deploy-s3-cloudfront"
  user = aws_iam_user.github_deploy.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3WebBucket"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.web.arn,
          "${aws_s3_bucket.web.arn}/*"
        ]
      },
      {
        Sid    = "S3ArtifactsBucket"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Sid      = "CloudFrontInvalidation"
        Effect   = "Allow"
        Action   = "cloudfront:CreateInvalidation"
        Resource = aws_cloudfront_distribution.web.arn
      }
    ]
  })
}

resource "aws_iam_access_key" "github_deploy" {
  user = aws_iam_user.github_deploy.name
}
