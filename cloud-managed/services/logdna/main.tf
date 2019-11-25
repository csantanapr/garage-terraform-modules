locals {
  tmp_dir            = "${path.cwd}/.tmp"
  short_name         = "logdna"
  namespaces         = ["${var.namespace}"]
  name_prefix        = "${var.name_prefix != "" ? var.name_prefix : var.resource_group_name}"
  service_name       = "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-${local.short_name}"
  service_class      = "logdna"
  binding_name       = "binding-${local.short_name}"
  binding_namespaces = "${jsonencode(local.namespaces)}"
  resource_location  = "${var.resource_location == "us-east" ? "us-south" : var.resource_location}"
  role               = "Manager"
  credentials_file   = "${local.tmp_dir}/logdna_credentials.json"
  ingestion_key_file = "${local.tmp_dir}/logdna_injestion_key.val"
}

resource "null_resource" "deploy_logdna" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-service.sh ${local.service_name} ${var.service_namespace} ${var.plan} ${local.service_class} ${local.binding_name} ${local.binding_namespaces} ${var.namespace}"

    environment {
      REGION         = "${local.resource_location}"
      RESOURCE_GROUP = "${var.resource_group_name}"
      TMP_DIR        = "${local.tmp_dir}"
    }
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "${path.module}/scripts/destroy-service.sh ${local.service_name} ${var.service_namespace} ${local.binding_name}"
  }
}

resource "null_resource" "create_tmp" {
  provisioner "local-exec" {
    command = "mkdir -p ${local.tmp_dir}"
  }
}

data "kubernetes_secret" "logdna_secret" {
  depends_on = ["null_resource.deploy_logdna"]

  metadata {
    name      = "${local.binding_name}"
    namespace = "${var.namespace}"
  }
}
resource "local_file" "write_logdna_credentials" {
  depends_on = ["null_resource.deploy_logdna", "null_resource.create_tmp"]

  content     = "${jsonencode(data.kubernetes_secret.logdna_secret.data)}"
  filename = "${local.credentials_file}"
}

resource "null_resource" "write_ingestion_key" {
  depends_on = ["local_file.write_logdna_credentials"]

  provisioner "local-exec" {
    command = "${path.module}/scripts/extract_json_value.sh ${local.credentials_file} ingestion_key > ${local.ingestion_key_file}"
  }
}

data "local_file" "injestion_key" {
  depends_on = ["null_resource.write_ingestion_key"]

  filename = "${local.ingestion_key_file}"
}

resource "null_resource" "logdna_bind" {

  provisioner "local-exec" {
    command = "${path.module}/scripts/bind-logdna.sh ${var.cluster_type} ${data.local_file.injestion_key.content} ${local.resource_location}"

    environment = {
      KUBECONFIG_IKS = "${var.cluster_config_file_path}"
      TMP_DIR        = "${local.tmp_dir}"
    }
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "${path.module}/scripts/unbind-logdna.sh ${var.namespace}"

    environment = {
      KUBECONFIG_IKS = "${var.cluster_config_file_path}"
    }
  }
}
