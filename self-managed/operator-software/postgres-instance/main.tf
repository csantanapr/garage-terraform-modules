locals {
  tmp_dir       = "${path.cwd}/.tmp"
  instance_parts = ["${var.database_name}", "postgresql"]
  instance_name = "${var.instance_name == "" ? join("-", local.instance_parts) : var.instance_name}"
  database_user = "${var.database_user == "" ? var.database_name : var.database_user}"
  database_name = "${var.database_name}"
  password_file = "${local.tmp_dir}/postgres_password.val"
  secret_name   = "postgres.${local.instance_name}.credentials"
}

resource "null_resource" "deploy_postgres" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-postgresql.sh ${var.namespace} ${local.instance_name} ${local.database_user} ${local.database_name} ${var.storage_class}"

    environment {
      KUBECONFIG_IKS     = "${var.cluster_config_file}"
      TMP_DIR            = "${local.tmp_dir}"
      OPERATOR_NAMESPACE = "${var.operator_namespace}"
    }
  }
}

resource "null_resource" "create_tmp" {
  provisioner "local-exec" {
    command = "mkdir -p ${local.tmp_dir}"
  }
}

resource "null_resource" "write_password" {
  depends_on = ["null_resource.deploy_postgres", "null_resource.create_tmp"]

  provisioner "local-exec" {
    command = "${path.module}/scripts/get-secret-value.sh ${local.secret_name} ${var.namespace} password > ${local.password_file}"

    environment {
      KUBECONFIG_IKS = "${var.cluster_config_file}"
    }
  }
}

data "local_file" "password" {
  depends_on = ["null_resource.write_password"]

  filename = "${local.password_file}"
}
