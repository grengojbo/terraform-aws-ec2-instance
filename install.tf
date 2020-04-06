
locals {
  public_ips = local.ellastic_ip > 0 ? var.eip_public_ips : aws_instance.this.*.public_ip
  sleep_restart_second = var.is_last_kernel ? 2 : 1
}

# resource "null_resource" "instance_restart" {
#   count = length(aws_instance.this.*.id)
#   provisioner "remote-exec" {
#     # when = "create"

#     inline = [
#       "sudo shutdown -r +60",
#       "echo 0",
#     ]
#     on_failure = "continue"
    
#     connection {
#       type        = "ssh"
#       user        = var.remote_user
#       private_key = file(var.infra_key)
#       host        = local.public_ips[count.index]
#     }
#   }
# }

resource "null_resource" "dependency_getter" {
  count = length(aws_instance.this.*.id)
  # triggers = {
  #   change_public_ips    = join(",", local.public_ips[*])
  # }
  provisioner "local-exec" {
    command = "sleep ${local.sleep_restart_second}; echo ${length(var.dependencies)}"
  }
  depends_on = [null_resource.instance_install, aws_instance.this]
}

resource "null_resource" "instance_install" {
  count = length(aws_instance.this.*.id)
  depends_on  = [aws_instance.this]

  triggers = {
    # change_public_ips    = join(",", aws_eip.ec2.*.public_ip[*])
    change_public_ips    = join(",", local.public_ips[*])
    cluster_instance_ids = join(",", aws_instance.this.*.id[*])
    change_private_ip    = join(",", aws_instance.this.*.private_ip[*])
    env_file             = sha1(file("${path.module}/templates/env"))
    change_variables     = sha1(local.is_dns)
    change_env           = sha1("${local.tenant}-${var.cert_storage}-${var.master_mode}-${var.master_type_ip}")
    etcd_private_ips     = sha1("https://${join(":2379,", local.etcd_private_ips[*])}:2379")
    change_public_ip     = "https://${join(" :2379,", local.etcd_public_ips[*])}:2379"
  }

  provisioner "file" {
    # content = locals.env_file
    content = templatefile("${path.module}/templates/env", merge(local.user_data, {
      name             = "${var.name}-${count.index + 1}"
      role             = var.component == "etcd" ? count.index == 0 ? "master" : "worker" : var.role
      etcd_join        = aws_instance.this.*.private_ip[0]
      etcd_join_public = local.public_ips[0]
      # etcd_join_public      = aws_eip.ec2.*.public_ip[0]
      etcd_cluster_name     = local.etcd_cluster_name
      etcd_endpoint_private = "https://${join(":2379,", local.etcd_private_ips[*])}:2379"
      etcd_endpoint_public  = "https://${join(":2379,", local.etcd_public_ips[*])}:2379"
      pkg_pke_url           = var.pkg_pke_url
      tenant                = local.tenant
      cert_storage          = var.cert_storage
      master_mode           = var.master_mode
      master_type_ip        = var.master_type_ip
    }))
    destination = "/home/${var.remote_user}/.env"

    connection {
      type        = "ssh"
      user        = var.remote_user
      private_key = file(var.infra_key)
      host        = local.public_ips[count.index]
      # host        = local.public_ips[count.index]
      # host        = aws_instance.this.*.public_dns[count.index]
    }
  }

}

# resource "null_resource" "instance_install" {
#   count = length(aws_instance.this.*.public_dns)

#   triggers = {
#     # change_public_ips    = join(",", local.public_ips[*])
#     change_public_ips    = join(",", aws_instance.this.*.public_ip[*])
#     cluster_instance_ids = join(",", aws_instance.this.*.id[*])
#     change_private_ip    = join(",", aws_instance.this.*.private_ip[*])
#     env_file             = sha1(file("${path.module}/templates/env"))
#     change_variables     = sha1(local.is_dns)
#     change_env           = sha1("${local.tenant}-${var.cert_storage}-${var.master_mode}-${var.master_type_ip}")
#     etcd_private_ips     = sha1("https://${join(":2379,", local.etcd_private_ips[*])}:2379")
#     change_public_ip     = sha1("https://${join(":2379,", local.etcd_public_ips[*])}:2379")
#   }

#   provisioner "file" {
#     # content = locals.env_file
#     content = templatefile("${path.module}/templates/env", merge(local.user_data, {
#       name                  = "${var.name}-${count.index + 1}"
#       role                  = var.component == "etcd" ? count.index == 0 ? "master" : "worker" : var.role
#       etcd_join             = aws_instance.this.*.private_ip[0]
#       etcd_join_public      = var.public_ip_type == "elastic" ? aws_eip.ec2.*.public_ip[0] : aws_instance.this.*.public_ip[0]
#       etcd_cluster_name     = local.etcd_cluster_name
#       etcd_endpoint_private = "https://${join(":2379,", local.etcd_private_ips[*])}:2379"
#       etcd_endpoint_public  = "https://${join(":2379,", local.etcd_public_ips[*])}:2379"
#       pkg_pke_url           = var.pkg_pke_url
#       tenant                = local.tenant
#       cert_storage          = var.cert_storage
#       master_mode           = var.master_mode
#       master_type_ip        = var.master_type_ip
#     }))
#     destination = "/home/${var.remote_user}/.env"
#     depends_on  = [aws_eip.ec2.*.public_ip[count.index]]

#     connection {
#       type        = "ssh"
#       user        = var.remote_user
#       private_key = file(var.infra_key)
#       host        = var.public_ip_type == "elastic" ? aws_eip.ec2.*.public_ip[count.index] : aws_instance.this.*.public_ip[count.index]
#       # host        = local.public_ips[count.index]
#       # host        = aws_instance.this.*.public_dns[count.index]
#     }
#   }

# }
