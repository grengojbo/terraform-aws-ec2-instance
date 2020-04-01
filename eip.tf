resource "aws_eip" "ec2" {
  count = var.public_ip_type == "elastic" ? var.instance_count : 0
  vpc   = true
  # vpc = false
  # lifecycle {
  #   prevent_destroy = true
  # }
  tags = merge(
    {
      "Name" = "EIP-${count.index}-${var.component}-${var.cluster_name}"
    },
    var.tags
  )
}

resource "aws_eip_association" "eip_assoc" {
  count         = var.public_ip_type == "elastic" ? var.instance_count : 0
  instance_id   = aws_instance.this[count.index].id
  allocation_id = aws_eip.ec2[count.index].id
}
