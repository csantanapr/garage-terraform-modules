locals {
  tmp_dir         = "${path.cwd}/.tmp"
  namespace       = var.cluster_type == "ocp4" ? "openshift-operators": "operators"
  operator-source = var.cluster_type == "ocp4" ? "community-operators" : "operatorhubio-catalog"
}

provider "kubernetes" {
  host     = var.server_url

  username = var.login_user
  password = var.login_password
}

resource "kubernetes_secret" "seed-secret" {
  metadata {
    name = "seed-secret"
    labels = {
      "seed.ibm.com/ibmcloud-token" = "apikey"
      "app.kubernetes.io/name"      = "ibmcloud-operator"
    }
  }

  data = {
    api-key = var.ibmcloud_api_key
    region  = var.resource_location
  }

  type = "Opaque"
}

resource "kubernetes_config_map" "example" {
  metadata {
    name = "seed-defaults"
    labels = {
      "app.kubernetes.io/name" = "ibmcloud-operator"
    }
  }

  data = {
    region        = var.resource_location
    resourceGroup = var.resource_group_name
    org           = ""
    space         = ""
  }
}

resource "null_resource" "deploy_cloud_operator" {
  depends_on = [
    kubernetes_secret.seed-secret,
    kubernetes_config_map.example,
  ]

  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-cloud-operator.sh ${var.olm_namespace} ${local.namespace} ${local.operator-source}"

    environment = {
      KUBECONFIG_IKS = var.cluster_config_file
      TMP_DIR        = local.tmp_dir
    }
  }
}
