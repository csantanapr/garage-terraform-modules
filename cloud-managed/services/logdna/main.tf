locals {
  short_name         = "logdna"
  namespaces         = ["${var.namespace}"]
  name_prefix        = "${var.name_prefix != "" ? var.name_prefix : var.resource_group_name}"
  service_name       = "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-${local.short_name}"
  service_class      = "logdna"
  binding_name       = "binding-${local.short_name}"
  binding_namespaces = "${jsonencode(local.namespaces)}"
  resource_location  = "${var.resource_location == "us-east" ? "us-south" : var.resource_location}"
  role               = "Manager"
}

resource "null_resource" "deploy_logdna" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-service.sh ${local.service_name} ${var.service_namespace} ${var.plan} ${local.service_class} ${local.binding_name} ${local.binding_namespaces}"

    environment {
      REGION = "${local.resource_location}"
    }
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "${path.module}/scripts/destroy-service.sh ${local.service_name} ${var.service_namespace} ${local.binding_name}"
  }
}

//resource "null_resource" "logdna_bind" {
//
//  provisioner "local-exec" {
//    command = "${path.module}/scripts/bind-logdna.sh ${var.cluster_type} ${ibm_resource_key.logdna_instance_key.credentials.ingestion_key} ${local.resource_location}"
//
//    environment = {
//      KUBECONFIG_IKS = "${var.cluster_config_file_path}"
//      TMP_DIR        = "${path.cwd}/.tmp"
//    }
//  }
//
//  provisioner "local-exec" {
//    when    = "destroy"
//    command = "${path.module}/scripts/unbind-logdna.sh ${var.namespace}"
//
//    environment = {
//      KUBECONFIG_IKS = "${var.cluster_config_file_path}"
//    }
//  }
//}
