locals {
  short_name         = "postgresql"
  namespaces         = ["${var.tools_namespace}", "${var.dev_namespace}", "${var.test_namespace}", "${var.staging_namespace}"]
  name_prefix        = "${var.name_prefix != "" ? var.name_prefix : var.resource_group_name}"
  service_name       = "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-${local.short_name}"
  service_class      = "databases-for-postgresql"
  binding_name       = "binding-${local.short_name}"
  binding_namespaces = "${jsonencode(local.namespaces)}"
  role               = "Administrator"
}

resource "null_resource" "deploy_postgres" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-service.sh ${local.service_name} ${var.service_namespace} ${var.plan} ${local.service_class} ${local.binding_name} ${local.binding_namespaces}"
  }
}

data "kubernetes_secret" "binding" {
  depends_on = ["null_resource.deploy_postgres"]
  metadata {
    name = "${local.binding_name}"
    namespace = "${var.tools_namespace}"
  }
}
