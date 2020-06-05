data "aws_kms_alias" "s3kmskey" {
  name = "alias/terraform"
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "codebuild.amazonaws.com",
        "codepipeline.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}