locals {
  tmp_dir         = "${path.cwd}/.tmp"
  namespace       = var.cluster_type == "ocp4" ? "openshift-operators": "operators"
  operator-source = var.cluster_type == "ocp4" ? "community-operators" : "operatorhubio-catalog"
}

resource "null_resource" "deploy_cloud_operator" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-cloud-operator.sh ${var.resource_location} ${var.olm_namespace} ${local.namespace} ${local.operator-source}"

    environment = {
      KUBECONFIG_IKS = var.cluster_config_file
      TMP_DIR        = local.tmp_dir
      APIKEY         = var.ibmcloud_api_key
      RESOURCE_GROUP = var.resource_group_name
    }
  }
}
