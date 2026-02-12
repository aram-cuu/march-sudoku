output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = "https://${aws_cloudfront_distribution.web.domain_name}"
}

output "web_bucket_name" {
  description = "Name of the S3 web bucket"
  value       = aws_s3_bucket.web.id
}

output "artifacts_bucket_name" {
  description = "Name of the S3 artifacts bucket"
  value       = aws_s3_bucket.artifacts.id
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.web.id
}

# output "github_deploy_access_key_id" {
#   description = "AWS access key ID for the GitHub Actions deploy user"
#   value       = aws_iam_access_key.github_deploy.id
# }

# output "github_deploy_secret_access_key" {
#   description = "AWS secret access key for the GitHub Actions deploy user (copy to GitHub Secrets after first apply)"
#   value       = aws_iam_access_key.github_deploy.secret
#   sensitive   = true
# }
