
resource "null_resource" "deploy_operator_lifecycle_manager" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-olm.sh ${var.olm_version}"

    environment {
      KUBECONFIG_IKS  = "${var.cluster_config_file}"
      CLUSTER_VERSION = "${var.cluster_version}"
    }
  }
}
