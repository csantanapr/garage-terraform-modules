resource "null_resource" "deploy_cloud_operator" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-cloud-operator.sh ${var.resource_group_name} ${var.resource_location}"

    environment {
      APIKEY = "${var.ibmcloud_api_key}"
    }
  }
}
