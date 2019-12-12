
resource "null_resource" "deploy_operator_lifecycle_manager" {
  count = "${replace(var.cluster_version, "/([0-9]).*/", "$1") == "4" ? 0 : 1 }"

  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-olm.sh ${var.olm_version}"

    environment {
      KUBECONFIG_IKS = "${var.cluster_config_file}"
    }
  }
}
