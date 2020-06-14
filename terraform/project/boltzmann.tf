resource "aws_s3_bucket" "boltzmann" {
  bucket = "www.boltzmann.dev"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_iam_user" "boltzmann" {
  name = "s3-deploys-writer"
  path = "/s3/users/writer/"
}

resource "aws_iam_access_key" "boltzmann" {
  user = aws_iam_user.boltzmann.name
}

resource "aws_iam_policy" "boltzmann" {
  name        = "boltzmann-writer"
  path        = "/s3/policies/bucket/boltzmann/"
  description = "boltzmann website bucket writers"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject"
    ],
    "Resource": ["${aws_s3_bucket.boltzmann.arn}/*"]
  }]
}
EOF
}

resource "aws_iam_user_policy_attachment" "boltzmann" {
  user       = aws_iam_user.boltzmann.name
  policy_arn = aws_iam_policy.boltzmann.arn
}

output "boltzmann_access_key_id" {
  value = aws_iam_access_key.boltzmann.id
}

output "boltzmann_access_secret_key" {
  value = aws_iam_access_key.boltzmann.secret
}
