locals {
  tmp_dir         = "${path.cwd}/.tmp"
  operator_source = var.cluster_type == "ocp4" ? "certified-operators" : "operatorhubio-catalog"
  operator_name   = var.cluster_type == "ocp4" ? "crunchy-postgres-operator" : "postgresql"
}

resource "null_resource" "deploy_postgres" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-postgresql-ocp4.sh ${var.olm_namespace} ${var.namespace} ${local.operator_name} ${local.operator_source}"

    environment = {
      KUBECONFIG_IKS = var.cluster_config_file
      TMP_DIR        = local.tmp_dir
    }
  }
}
