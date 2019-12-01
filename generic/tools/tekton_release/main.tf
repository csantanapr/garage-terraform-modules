provider "null" {
}

locals {
  ingress_host     = "tekton.${var.cluster_ingress_hostname}"
  tekton_namespace = "tekton-pipelines"
  tmp_dir          = "${path.cwd}/.tmp"
}

resource "null_resource" "tekton_sub" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-tekton.sh"

    environment = {
      KUBECONFIG_IKS = "${var.cluster_config_file_path}"
      TMP_DIR        = "${local.tmp_dir}"
    }
  }
}

resource "null_resource" "tekton_webhook" {
  depends_on = ["null_resource.tekton_sub"]
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-tekton-webhook.sh ${local.tekton_namespace} ${var.cluster_ingress_hostname}"

    environment = {
      KUBECONFIG_IKS = "${var.cluster_config_file_path}"
      TMP_DIR        = "${local.tmp_dir}"
    }
  }
}

resource "null_resource" "tekton_dashboard" {
  depends_on = ["null_resource.tekton_sub"]
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-tekton-dashboard.sh ${local.tekton_namespace} ${local.ingress_host}"

    environment = {
      KUBECONFIG_IKS = "${var.cluster_config_file_path}"
      TMP_DIR        = "${local.tmp_dir}"
    }
  }
}

resource "null_resource" "copy_cloud_configmap" {
  depends_on = ["null_resource.tekton_dashboard"]

  provisioner "local-exec" {
    command = "${path.module}/scripts/copy-configmap-to-namespace.sh tekton-config tools tekton-pipelines"

    environment = {
      KUBECONFIG_IKS = "${var.cluster_config_file_path}"
    }
  }
}
