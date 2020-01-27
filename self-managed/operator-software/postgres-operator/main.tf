locals {
  tmp_dir       = "${path.cwd}/.tmp"
}

resource "null_resource" "deploy_postgres" {
  count      = "${var. == "openshift" ? "1": "0"}"

  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-postgresql.sh ${var.namespace}"

    environment {
      KUBECONFIG_IKS = "${var.cluster_config_file}"
      TMP_DIR        = "${local.tmp_dir}"
      OLM_NAMESPACE  = "${var.olm_namespace}"
    }
  }
}

resource "null_resource" "deploy_postgres" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-postgresql.sh ${var.namespace}"

    environment {
      KUBECONFIG_IKS = "${var.cluster_config_file}"
      TMP_DIR        = "${local.tmp_dir}"
      OLM_NAMESPACE  = "${var.olm_namespace}"
    }
  }
}
