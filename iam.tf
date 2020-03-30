resource "aws_iam_role" "ec2" {
  # count = var.etcd_enabled ? 1 : 0
  name = "${var.component}-${var.cluster_name}-role"
  # name  = "${var.component}-${var.cluster_name}-role"

  tags = merge(
    {
      "Name" = "${var.component}-${var.cluster_name}-role"
    },
    var.tags
  )

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
      }
  ]
}
EOF
}

# #Add AWS Policies for Kubernetes

resource "aws_iam_role_policy" "ec2" {
  # count = var.etcd_enabled ? 1 : 0
  name = "${var.component}-${var.cluster_name}-police"
  # name  = "${var.component}-${var.cluster_name}-police"
  role = aws_iam_role.ec2.id

  policy = templatefile("${path.module}/templates/ec2-police.json", {
    # modules/etcd_ec2/templates/ec2-police.json
    bucket    = "${var.s3_bucket}/data"
    s3_bucket = var.s3_bucket
  })
}

# # #Create AWS Instance Profiles

resource "aws_iam_instance_profile" "ec2" {
  # count = var.etcd_enabled ? 1 : 0
  name = "${var.component}-${var.cluster_name}-profile"
  role = aws_iam_role.ec2.name
}

# resource "aws_iam_instance_profile" "kube-worker" {
#   name = "kube_${var.cluster_name}_node_profile"
#   role = "${aws_iam_role.kube-worker.name}"
# }
