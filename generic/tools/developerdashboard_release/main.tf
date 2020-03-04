locals {
  tmp_dir      = "${path.cwd}/.tmp"
  ingress_host = "dashboard.${var.cluster_ingress_hostname}"
}

resource "null_resource" "developerdashboard_release" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-dashboard.sh ${var.releases_namespace} ${var.cluster_type} dashboard ${var.cluster_ingress_hostname} ${var.image_tag}"

    environment = {
      KUBECONFIG_IKS  = "${var.cluster_config_file}"
      TLS_SECRET_NAME = "${var.tls_secret_name}"
      TMP_DIR         = "${local.tmp_dir}"
    }
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "${path.module}/scripts/destroy-dashboard.sh ${var.releases_namespace}"

    environment = {
      KUBECONFIG_IKS = "${var.cluster_config_file}"
    }
  }
}
