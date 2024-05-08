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
        "Sid" : "TerraformBackendS3",
        "Effect" : "Allow",
        "Action" : [
          "s3:*"
        ],
        "Resource" : "arn:aws:s3:::cv-benjamesdodwell-com-terraform/*/terraform.tfstate"
      },
      {
        "Sid" : "TerraformBackendDynamoDB",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:*"
        ],
        "Resource" : "arn:aws:dynamodb:eu-west-2:231055119230:table/cv-benjamesdodwell-com-terraform"
      },
      {
        "Sid" : "DynamoDBActions",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:*"
        ],
        "Resource" : "arn:aws:dynamodb:eu-west-2:231055119230:table/Visits"
      },
      {
        "Sid" : "IAMActions",
        "Effect" : "Allow",
        "Action" : [
          "iam:*"
        ],
        "Resource" : "arn:aws:iam::231055119230:role/LambdaAssumeRole"
      },
      {
        "Sid" : "LambdaActions",
        "Effect" : "Allow",
        "Action" : [
          "lambda:*"
        ],
        "Resource" : "arn:aws:lambda:eu-west-2:231055119230:function:IncrementVisits"
      },
      {
        "Sid" : "Route53Actions",
        "Effect" : "Allow",
        "Action" : [
          "route53:*"
        ],
        "Resource" : "arn:aws:route53:::hostedzone/Z0120439X7MX2MFD3KQR"
      },
      {
        "Sid" : "TerraformActions",
        "Effect" : "Allow",
        "Action" : [
          "acm:DescribeCertificate",
          "acm:RequestCertificate",
          "acm:ListTagsForCertificate",
          "acm:DeleteCertificate",
          "apigateway:GET",
          "apigateway:POST",
          "apigateway:DELETE",
          "route53:ListHostedZones",
          "route53:GetChange"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "github_actions_terraform_role" {
  name = "GitHubActionsTerraformRole"

  assume_role_policy = data.aws_iam_policy_document.assume_role_github.json
}
