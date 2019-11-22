locals {
  short_name         = "cloudant"
  namespaces         = ["${var.dev_namespace}", "${var.test_namespace}", "${var.staging_namespace}"]
  name_prefix        = "${var.name_prefix != "" ? var.name_prefix : var.resource_group_name}"
  service_name       = "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-${local.short_name}"
  service_class      = "cloudantnosqldb"
  binding_name       = "binding-${local.short_name}"
  binding_namespaces = "${jsonencode(local.namespaces)}"
  role               = "Manager"
}

resource "null_resource" "deploy_cloudant" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-service.sh ${local.service_name} ${var.service_namespace} ${var.plan} ${local.service_class} ${local.binding_name} ${local.binding_namespaces}"

    environment {
      RESOURCE_GROUP = "${var.resource_group_name}"
      REGION         = "${var.resource_location}"
    }
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "${path.module}/scripts/destroy-service.sh ${local.service_name} ${var.service_namespace} ${local.binding_name}"
  }
}
