resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
}

data "aws_iam_policy_document" "assume_role_github" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::231055119230:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:ben-james-dodwell/backend-cv-benjamesdodwell-com:*",
        "repo:ben-james-dodwell/frontend-cv-benjamesdodwell-com:*",
        "repo:ben-james-dodwell/blog-cv-benjamesdodwell-com:*",
      ]
    }
  }
}

resource "aws_iam_role_policy" "terraform_policy" {
  name = "TerraformPolicy"
  role = aws_iam_role.github_actions_terraform_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:*"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3:::${var.bucket}/*",
        "Sid" : "TerraformBackendS3"
      },
      {
        "Action" : [
          "dynamodb:*"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:dynamodb:eu-west-2:231055119230:table/${var.dynamodb_table}",
        "Sid" : "TerraformBackendDynamoDB"
      },
      {
        "Action" : [
          "dynamodb:*"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:dynamodb:eu-west-2:231055119230:table/Visits",
        "Sid" : "DynamoDBActions"
      },
      {
        "Action" : [
          "iam:*"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:iam::231055119230:role/LambdaAssumeRole",
        "Sid" : "IAMActions"
      },
      {
        "Action" : [
          "lambda:*"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:lambda:eu-west-2:231055119230:function:IncrementVisits",
        "Sid" : "LambdaActions"
      },
      {
        "Action" : [
          "route53:*"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:route53:::hostedzone/Z0120439X7MX2MFD3KQR",
        "Sid" : "Route53Actions"
      },
      {
        "Action" : [
          "s3:*"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${var.frontend_bucket}/*",
          "arn:aws:s3:::${var.frontend_bucket}",
          "arn:aws:s3:::${var.blog_bucket}/*",
          "arn:aws:s3:::${var.blog_bucket}"
        ],
        "Sid" : "S3Actions"
      },
      {
        "Action" : [
          "acm:DescribeCertificate",
          "acm:RequestCertificate",
          "acm:ListTagsForCertificate",
          "acm:DeleteCertificate",
          "apigateway:GET",
          "apigateway:POST",
          "apigateway:DELETE",
          "cloudfront:GetDistribution",
          "cloudfront:ListTagsForResource",
          "cloudfront:CreateDistribution",
          "cloudfront:TagResource",
          "cloudfront:CreateInvalidation",
          "route53:ListHostedZones",
          "route53:GetChange"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "TerraformActions"
      }
    ]
  })
}

resource "aws_iam_role" "github_actions_terraform_role" {
  name = "GitHubActionsTerraformRole"

  assume_role_policy = data.aws_iam_policy_document.assume_role_github.json
}
