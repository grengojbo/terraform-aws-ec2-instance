resource "null_resource" "instance_install" {
  count = length(aws_instance.this.*.public_dns)

  triggers = {
    cluster_instance_ids = join(",", aws_instance.this.*.id[*])
    env_file             = sha1(file("${path.module}/templates/env"))
    change_variables     = sha1(local.is_dns)
    change_env           = sha1("${local.tenant}-${var.cert_storage}-${var.master_mode}-${var.master_type_ip}")
    etcd_private_ips     = sha1("https://${join(":2379,", local.etcd_private_ips[*])}:2379")
    change_public_ip     = sha1("https://${join(":2379,", local.etcd_public_ips[*])}:2379")
  }

  provisioner "file" {
    # content = locals.env_file
    content = templatefile("${path.module}/templates/env", merge(local.user_data, {
      name                  = "${var.name}-${count.index + 1}"
      role                  = var.component == "etcd" ? count.index == 0 ? "master" : "worker" : var.role
      etcd_join             = aws_instance.this.*.private_ip[0]
      etcd_join_public      = aws_instance.this.*.public_ip[0]
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
      host        = aws_instance.this.*.public_dns[count.index]
    }
  }

}
