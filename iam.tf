module "etcd_backup_user" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-user"
  version                       = "~> 2.0"
  name                          = "${var.cluster_name}_${var.name}_backup"
  create_iam_user_login_profile = false
  create_iam_access_key         = true
  # force_destroy                 = true
  # pgp_key = "keybase:test"
  # password_reset_required = false
}

resource "aws_iam_role" "etcd" {
  name = "etcd-${var.cluster_name}-role"

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

resource "aws_iam_role_policy" "etcd" {
  name = "etcd-${var.cluster_name}-police"
  role = aws_iam_role.etcd.id

  policy = templatefile("${path.module}/templates/ec2-police.json", {
    # modules/etcd_ec2/templates/ec2-police.json
    bucket    = "${var.s3_bucket}/data"
    s3_bucket = var.s3_bucket
  })
}

resource "aws_iam_user_policy" "etcd_backup_user" {
  name = "etcd-backup-user-police"
  user = module.etcd_backup_user.this_iam_user_name

  policy = templatefile("${path.module}/templates/s3-police.json", {
    bucket           = "${var.s3_bucket}/data"
    s3_bucket        = var.s3_bucket
    s3_bucket_backup = local.s3_bucket_backup
  })
}

# # #Create AWS Instance Profiles

resource "aws_iam_instance_profile" "etcd" {
  name = "etcd_${var.cluster_name}_profile"
  role = aws_iam_role.etcd.name
}

# resource "aws_iam_instance_profile" "kube-worker" {
#   name = "kube_${var.cluster_name}_node_profile"
#   role = "${aws_iam_role.kube-worker.name}"
# }
