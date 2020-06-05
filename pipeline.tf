resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-us-east-1-1234567890"
  acl    = "private"
  policy = "${file("s3_bucket_policy.json")}"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  
}

resource "aws_iam_role_policy_attachment" "admin-access-policy" {
    role = aws_iam_role.codepipeline_role.name
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


resource "aws_codepipeline" "codepipeline" {
  name     = "tf-test-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.s3kmskey.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["baseline_output"]

      configuration = {
        OAuthToken = "35199ef6520e0d638b6018cdbb838169f8206e44"
        Owner  = "nimishmehta8779"
        Repo   = "codepipeline"
        Branch = "master"
        PollForSourceChanges = true
      }
    }
  }

 stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["baseline_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      role_arn         = "arn:aws:iam::086706880215:role/cross_account_build"
      configuration = {
        ProjectName = "test"
      }
    }
  }
}