resource "aws_iam_role" "yimby-qa-iam-role" {
  name        = "${local.name}-iam-role"
  description = "This role is created for jenkins and backend/frontend server so that they can access ECR for login, image pushing and image pulling."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "policies-for-yimby-qa-iam-role" {
  for_each = toset([
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds",
    "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])

  role       = aws_iam_role.yimby-qa-iam-role.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "yimby-qa-instance-profile" {
  name = "${local.name}-instance-profile"
  role = aws_iam_role.yimby-qa-iam-role.name
}