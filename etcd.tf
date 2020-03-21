resource "null_resource" "etcd_install" {
  count = length(aws_instance.this.*.public_dns)

  triggers = {
    cluster_instance_ids  = join(",", aws_instance.this.*.id[*])
    install_pke_file      = sha1(file("${path.module}/templates/install-pke"))
    etcd_member_list_file = sha1(file("${path.module}/templates/etcd-member-list"))
    pke_etcd_file         = sha1(file("${path.module}/templates/pke-etcd.yaml"))
    env_file              = sha1(file("${path.module}/templates/env"))
    change_variables      = sha1(local.is_dns)
  }

  provisioner "file" {
    # content = locals.env_file
    content = templatefile("${path.module}/templates/env", merge(local.user_data, {
      name      = "${var.name}-${count.index + 1}"
      role      = count.index == 0 ? "master" : "worker"
      etcd_join = aws_instance.this.*.private_ip[0]
    }))
    destination = "/home/${var.remote_user}/.env"

    connection {
      type        = "ssh"
      user        = var.remote_user
      private_key = file(var.infra_key)
      host        = aws_instance.this.*.public_dns[count.index]
    }
  }

  provisioner "file" {
    source      = "${path.module}/templates/pke-etcd.yaml"
    destination = "/home/${var.remote_user}/pke-etcd.yaml"

    connection {
      type        = "ssh"
      user        = var.remote_user
      private_key = file(var.infra_key)
      host        = aws_instance.this.*.public_dns[count.index]
    }
  }

  provisioner "file" {
    source      = "${path.module}/templates/etcd-member-list"
    destination = "/home/${var.remote_user}/bin/etcd-member-list"

    connection {
      type        = "ssh"
      user        = var.remote_user
      private_key = file(var.infra_key)
      host        = aws_instance.this.*.public_dns[count.index]
    }
  }

  provisioner "file" {
    source      = "${path.module}/templates/install-pke"
    destination = "/home/${var.remote_user}/bin/install-pke"

    connection {
      type        = "ssh"
      user        = var.remote_user
      private_key = file(var.infra_key)
      host        = aws_instance.this.*.public_dns[count.index]
    }
  }

  provisioner "remote-exec" {
    inline = [
      "test ! -d /home/${var.remote_user}/bin || sudo chmod -R +x /home/${var.remote_user}/bin",
      "sudo mv /home/${var.remote_user}/bin/install-pke /usr/bin/install-pke",
      "sudo mv /home/${var.remote_user}/bin/etcd-member-list /usr/bin/etcd-member-list",
      "sudo cp /home/${var.remote_user}/pke-etcd.yaml /root/pke-etcd.yaml",
      "sudo cp /home/${var.remote_user}/.env /.env",
      "sudo /usr/bin/install-pke",
      # "sudo mv ",
      #  pke-etcd snapshot save-s3 --region "${S3_REGION}" --bucket "${S3_BUCKET}" --install-scheduled
      # "/tmp/script.sh args",
    ]
    connection {
      type        = "ssh"
      user        = var.remote_user
      private_key = file(var.infra_key)
      host        = aws_instance.this.*.public_dns[count.index]
    }
  }
  # depends_on = [null_resource.etcd_install, null_resource.etcd_pke]
}

# resource "null_resource" "etcd_backup_add" {
#   depends_on = [null_resource.etcd_install]
#   count      = var.backup_count > 0 ? 1 : 0

#   triggers = {
#     etcd_backup = var.backup_count
#   }

#   provisioner "remote-exec" {
#     inline = [
#       # "sudo -s",
#       "export AWS_ACCESS_KEY_ID=${module.etcd_backup_user.this_iam_access_key_id}",
#       "export AWS_SECRET_ACCESS_KEY=${module.etcd_backup_user.this_iam_access_key_secret}",
#       "sudo --preserve-env=AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY /usr/bin/pke-etcd snapshot save-s3 --region='${local.s3_region}' --bucket='${local.s3_bucket_backup}' --schedule='${var.backup_schedule}' --install-scheduled"
#     ]
#     connection {
#       type        = "ssh"
#       user        = var.remote_user
#       private_key = file(var.infra_key)
#       host        = aws_instance.this.*.public_dns[var.backup_count - 1]
#     }
#   }
# }
# # # resource "null_resource" "etcd_install" {
# # #   dynamic provisioner {
# # #     for_each = module.etcd.public_dns
# # #     content file {
# # #       source      = "./templates/pke-etcd.yaml"
# # #       destination = "/home/centos/pke-etcd1.yaml"

# # #       connection {
# # #         content {
# # #           type        = "ssh"
# # #           user        = var.remote_user
# # #           private_key = file(var.infra_key)
# # #           host        = public_dns.value
# # #         }
# # #       }
# # #     }
# # #   }
# # # }
