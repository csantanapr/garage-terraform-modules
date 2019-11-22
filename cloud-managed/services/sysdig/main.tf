
// SysDig - Monitoring
resource "ibm_resource_instance" "sysdig_instance" {
  name              = "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-sysdig"
  service           = "sysdig-monitor"
  plan              = "${var.plan}"
  location          = "${var.resource_location}"
  resource_group_id = "${data.ibm_resource_group.tools_resource_group.id}"

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

locals {
//  access_key  = "${ibm_resource_key.sysdig_instance_key.credentials["Sysdig Access Key"]}"
//  endpoint    = "${ibm_resource_key.sysdig_instance_key.credentials["Sysdig Collector Endpoint"]}"
  short_name         = "sysdig"
  namespaces         = ["${var.tools_namespace}"]
  name_prefix        = "${var.name_prefix != "" ? var.name_prefix : var.resource_group_name}"
  service_name       = "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-${local.short_name}"
  service_class      = "sysdig-monitor"
  binding_name       = "binding-${local.short_name}"
  binding_namespaces = "${jsonencode(local.namespaces)}"
  role               = "Manager"
}

resource "null_resource" "deploy_logdna" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-service.sh ${local.service_name} ${var.service_namespace} ${var.plan} ${local.service_class} ${local.binding_name} ${local.binding_namespaces}"

    environment {
      REGION = "${var.resource_location}"
    }
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "${path.module}/scripts/destroy-service.sh ${local.service_name} ${var.service_namespace} ${local.binding_name}"
  }
}

//resource "null_resource" "create_sysdig_agent" {
//  depends_on = ["ibm_resource_key.sysdig_instance_key"]
//
//  provisioner "local-exec" {
//    command = "${path.module}/scripts/bind-sysdig.sh ${local.access_key} ${local.endpoint}"
//
//    environment = {
//      KUBECONFIG_IKS = "${var.cluster_config_file_path}"
//    }
//  }
//
//  provisioner "local-exec" {
//    when    = "destroy"
//    command = "${path.module}/scripts/unbind-sysdig.sh"
//
//    environment = {
//      KUBECONFIG_IKS = "${var.cluster_config_file_path}"
//    }
//  }
//}
