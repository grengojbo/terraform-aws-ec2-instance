data "aws_ami" "latest" {
  owners      = var.ami_owners
  most_recent = true
  filter {
    name   = "name"
    values = ["${var.etcd_ami_prefix}-*"]
  }
}

locals {
  hostname                    = var.name
  s3_region                   = var.s3_region
  s3_bucket_backup            = "${var.name}-${var.cluster_name}-backup"
  is_lb                       = var.dns_zone_id != "none" && var.domain_name != "none" && var.instance_count > 1 && var.etcd_lb_enabled ? var.instance_count : 0
  is_dns                      = local.is_lb == 0 && var.dns_zone_id != "none" && var.domain_name != "none" && var.instance_count > 0 ? var.instance_count : 0
  domain_public               = local.is_dns > 0 || local.is_lb > 0 ? var.domain_name : "none"
  domain_private              = local.is_dns > 0 || local.is_lb > 0 ? "${var.s3_region}.${var.domain_name}" : "none"
  is_t_instance_type          = replace(var.instance_type, "/^t[23]{1}\\..*$/", "1") == "1" ? true : false
  iam_instance_profile        = var.conponent == "etcd" ? aws_iam_instance_profile.etcd.name : ""
  associate_public_ip_address = var.public_ip_type == "assotiation" ? true : null
  ellastic_ip                 = var.public_ip_type == "elastic" ? 1 : 0

  dev_show = {
    s3_bucket_backup            = local.s3_bucket_backup
    is_lb                       = local.is_lb
    is_dns                      = local.is_dns
    domain_public               = local.domain_public
    domain_private              = local.domain_private
    is_t_instance_type          = local.is_t_instance_type
    iam_instance_profile        = local.iam_instance_profile
    associate_public_ip_address = local.associate_public_ip_address
    ellastic_ip                 = local.ellastic_ip
  }

  user_data = {
    node_name             = local.hostname
    remote_user           = var.remote_user
    k8s_enabled           = var.k8s_enabled
    cluster_name          = var.cluster_name
    etcd_enabled          = var.etcd_enabled
    pke_etcd_version      = var.pke_etcd_version
    bucket_data           = var.bucket_data
    s3_region             = var.s3_region
    s3_bucket             = var.s3_bucket
    etcd_provider         = var.etcd_provider
    domain_name           = var.domain_name
    node_exporter_enabled = var.node_exporter_enabled
    fluetbit_enabled      = var.fluetbit_enabled
    lvm_enabled           = var.lvm_enabled
    etcd_recovery         = var.etcd_recovery
    etcd_lb_enabled       = var.etcd_lb_enabled
    etcd_dns_srv_enabled  = local.is_dns
    domain_private        = local.domain_private
    domain_public         = local.domain_public
    etcd_wait_first_node  = var.etcd_wait_first_node
    install_packages      = var.install_packages
    is_last_kernel        = var.is_last_kernel
  }

  root_block_device = [
    {
      delete_on_termination = true
      volume_type           = var.volume_type
      volume_size           = var.root_volume_size
    },
  ]
}

resource "aws_instance" "this" {
  # count = 0
  count            = var.instance_count
  ami              = var.ami == "last" ? data.aws_ami.latest.id : var.ami
  instance_type    = lookup(var.etcd_instance_types, var.instance_type)
  user_data        = templatefile("${path.module}/templates/user_data.sh", local.user_data)
  user_data_base64 = var.user_data_base64
  subnet_id = length(var.network_interface) > 0 ? null : element(
    distinct(compact(concat([var.subnet_id], var.subnet_ids))),
    count.index,
  )
  key_name               = var.key_name
  monitoring             = var.monitoring
  get_password_data      = var.get_password_data
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = local.iam_instance_profile

  associate_public_ip_address = local.associate_public_ip_address
  private_ip                  = length(var.private_ips) > 0 ? element(var.private_ips, count.index) : var.private_ip
  ipv6_address_count          = var.ipv6_address_count
  ipv6_addresses              = var.ipv6_addresses

  ebs_optimized = var.ebs_optimized

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  lifecycle {
    # "private_ip", "root_block_device", "ebs_block_device"
    ignore_changes = [ami, user_data, key_name]
  }

  dynamic "network_interface" {
    for_each = var.network_interface
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = lookup(network_interface.value, "network_interface_id", null)
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", false)
    }
  }

  source_dest_check                    = length(var.network_interface) > 0 ? null : var.source_dest_check
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  placement_group                      = var.placement_group
  tenancy                              = var.tenancy

  tags = merge(
    {
      "Name" = var.instance_count > 1 || var.use_num_suffix ? format("%s-%d", var.name, count.index + 1) : var.name
    },
    var.tags,
  )

  volume_tags = merge(
    {
      "Name" = var.instance_count > 1 || var.use_num_suffix ? format("%s-%d", var.name, count.index + 1) : var.name
    },
    var.volume_tags,
  )

  credit_specification {
    cpu_credits = local.is_t_instance_type ? var.cpu_credits : null
  }
}
