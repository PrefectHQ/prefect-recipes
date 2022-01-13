resource "aws_iam_policy" "eks_node_group" {
  name        = "data_eks_policy"
  path        = "/"
  description = "Additional EKS Node permission"
  policy      = data.aws_iam_policy_document.eks_node_group.json
}

data "aws_iam_policy_document" "eks_node_group" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = module.eks.worker_iam_role_name
  policy_arn = aws_iam_policy.eks_node_group.arn
}