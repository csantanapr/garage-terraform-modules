locals {
  short_name         = "appid"
  namespaces         = ["${var.dev_namespace}", "${var.test_namespace}", "${var.staging_namespace}"]
  name_prefix        = "${var.name_prefix != "" ? var.name_prefix : var.resource_group_name}"
  region             = "${var.resource_location == "us-east" ? "us-south" : var.resource_location}"
  service_name       = "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-${local.short_name}"
  service_class      = "appid"
  binding_name       = "binding-${local.short_name}"
  binding_namespaces = "${jsonencode(local.namespaces)}"
}

// AppID - App Authentication
resource "null_resource" "deploy_appid" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-service.sh ${local.service_name} ${var.service_namespace} ${var.plan} ${local.service_class} ${local.binding_name} ${local.binding_namespaces}"

    environment {
      REGION = "${local.region}"
    }
  }
}
