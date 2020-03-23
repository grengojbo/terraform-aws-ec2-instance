resource "null_resource" "instance_install" {
  count = length(aws_instance.this.*.public_dns)

  triggers = {
    cluster_instance_ids = join(",", aws_instance.this.*.id[*])
    env_file             = sha1(file("${path.module}/templates/env"))
    change_variables     = sha1(local.is_dns)
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

}
