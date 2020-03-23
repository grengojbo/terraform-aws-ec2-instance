# output "iam_role_etcd" {
#   value = aws_iam_role.etcd
# }

# output "iam_etcd_backup_user" {
#   value = module.etcd_backup_user
# }

# output "iam_etcd_policy_data" {
#   value = aws_iam_role_policy.etcd
# }

# output "iam_etcd_backup_user_police" {
#   value = aws_iam_user_policy.etcd_backup_user
# }

# output "iam_etcd_instance_profile" {
#   value = aws_iam_instance_profile.etcd
# }

# output "dev_show" {
#   value = local.dev_show
# }
# output "user_data" {
#   value = local.user_data
# }

# output "aa_instantes" {
#   description = "Show All instance"
#   value = aws_instance.this
# }

output "id" {
  description = "List of IDs of instances"
  value       = aws_instance.this.*.id
}

output "arn" {
  description = "List of ARNs of instances"
  value       = aws_instance.this.*.arn
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.this.*.public_dns
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.this.*.public_ip
}

output "private_dns" {
  description = "List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.this.*.private_dns
}

output "private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = aws_instance.this.*.private_ip
}

output "instance_state" {
  description = "List of instance states of instances"
  value       = aws_instance.this.*.instance_state
}

output "backup_user_key" {
  value = module.etcd_backup_user.this_iam_access_key_id
}

output "backup_user_secret" {
  value = module.etcd_backup_user.this_iam_access_key_secret
}

output "backup" {
  value = [
    "export AWS_ACCESS_KEY_ID=${module.etcd_backup_user.this_iam_access_key_id}",
    "export AWS_SECRET_ACCESS_KEY=${module.etcd_backup_user.this_iam_access_key_secret}"
  ]
}

output "z_connects" {
  description = "SSH connection to instance"
  value       = [for s in aws_instance.this.*.public_dns : "ssh centos@${s}"]
}

# TODO: востаноыить то что нужно
# output "result" {
#   value = {
#     dns = {
#       srv = local.is_dns > 0 ? true : false
#       lb  = local.is_lb > 0 ? true : false
#     },
#     records = {
#       public  = "${local.hostname}.${local.domain_public}",
#       privare = "${local.hostname}.${local.domain_private}"
#     },
#     privare = aws_route53_record.peers_private.*.name,
#     public  = aws_route53_record.peers_public.*.name
#   }
# }

# output "route53" {
#   value = aws_route53_record.peers_public.*.name
# }
# # output "vpc_security_group_ids" {
# #   description = "List of VPC security group ids assigned to the instances"
# #   value       = module.etcd.vpc_security_group_ids
# # }

# # output "root_block_device_volume_ids" {
# #   description = "List of volume IDs of root block devices of instances"
# #   value       = module.etcd.root_block_device_volume_ids
# # }

# # output "ebs_block_device_volume_ids" {
# #   description = "List of volume IDs of EBS block devices of instances"
# #   value       = module.etcd.ebs_block_device_volume_ids
# # }

# # output "tags" {
# #   description = "List of tags"
# #   value       = module.etcd.tags
# # }

# # output "placement_group" {
# #   description = "List of placement group"
# #   value       = module.etcd.placement_group
# # }

# # output "instance_id" {
# #   description = "EC2 instance ID"
# #   value       = module.etcd.id[0]
# # }

# # output "instance_public_dns" {
# #   description = "Public DNS name assigned to the EC2 instance"
# #   value       = module.etcd.public_dns[0]
# # }

# # output "credit_specification" {
# #   description = "Credit specification of EC2 instance (empty list for not t2 instance types)"
# #   value       = module.etcd.credit_specification
# # }

# -------- OLD -----------------

# output "availability_zone" {
#   description = "List of availability zones of instances"
#   value       = aws_instance.this.*.availability_zone
# }

# output "placement_group" {
#   description = "List of placement groups of instances"
#   value       = aws_instance.this.*.placement_group
# }

# output "key_name" {
#   description = "List of key names of instances"
#   value       = aws_instance.this.*.key_name
# }

# output "password_data" {
#   description = "List of Base-64 encoded encrypted password data for the instance"
#   value       = aws_instance.this.*.password_data
# }

# output "ipv6_addresses" {
#   description = "List of assigned IPv6 addresses of instances"
#   value       = aws_instance.this.*.ipv6_addresses
# }

# output "primary_network_interface_id" {
#   description = "List of IDs of the primary network interface of instances"
#   value       = aws_instance.this.*.primary_network_interface_id
# }

# output "security_groups" {
#   description = "List of associated security groups of instances"
#   value       = aws_instance.this.*.security_groups
# }

# output "vpc_security_group_ids" {
#   description = "List of associated security groups of instances, if running in non-default VPC"
#   value       = aws_instance.this.*.vpc_security_group_ids
# }

# output "subnet_id" {
#   description = "List of IDs of VPC subnets of instances"
#   value       = aws_instance.this.*.subnet_id
# }

# output "credit_specification" {
#   description = "List of credit specification of instances"
#   value       = aws_instance.this.*.credit_specification
# }


# output "root_block_device_volume_ids" {
#   description = "List of volume IDs of root block devices of instances"
#   value       = [for device in aws_instance.this.*.root_block_device : device.*.volume_id]
# }

# output "ebs_block_device_volume_ids" {
#   description = "List of volume IDs of EBS block devices of instances"
#   value       = [for device in aws_instance.this.*.ebs_block_device : device.*.volume_id]
# }

# output "tags" {
#   description = "List of tags of instances"
#   value       = aws_instance.this.*.tags
# }

# output "volume_tags" {
#   description = "List of tags of volumes of instances"
#   value       = aws_instance.this.*.volume_tags
# }

# output "instance_count" {
#   description = "Number of instances to launch specified as argument to this module"
#   value       = var.instance_count
# }
