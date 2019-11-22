locals {
  namespaces         = ["${var.tools_namespace}", "${var.dev_namespace}", "${var.test_namespace}", "${var.staging_namespace}"]
  namespace_count    = 4
  tmp_dir            = "${path.cwd}/.tmp"
  credentials_file   = "${path.cwd}/.tmp/postgres_credentials.json"
  hostname_file      = "${path.cwd}/.tmp/postgres_hostname.val"
  port_file          = "${path.cwd}/.tmp/postgres_port.val"
  username_file      = "${path.cwd}/.tmp/postgres_username.val"
  password_file      = "${path.cwd}/.tmp/postgres_password.val"
  dbname_file        = "${path.cwd}/.tmp/postgres_dbname.val"
  role               = "Administrator"
  name_prefix        = "${var.name_prefix != "" ? var.name_prefix : var.resource_group_name}"
  service_class      = "databases-for-postgresql"
  service_name       = "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-postgresql"
  binding_name       = "binding-postgresql"
  binding_namespaces = "${jsonencode(local.namespaces)}"
}

resource "null_resource" "deploy_postgres" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deploy-service.sh ${local.service_name} ${var.service_namespace} ${var.plan} ${local.service_class} ${local.binding_name} ${local.binding_namespaces} ${var.tools_namespace}"

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

resource "null_resource" "create_tmp" {
  provisioner "local-exec" {
    command = "mkdir -p ${local.tmp_dir}"
  }
}

data "kubernetes_secret" "postgres_secret" {
  depends_on = ["null_resource.deploy_postgres"]

  metadata {
    name      = "${local.binding_name}"
    namespace = "${var.tools_namespace}"
  }
}

// This is SUPER kludgy but it works... Need to revisit
resource "local_file" "write_postgres_credentials" {
  content     = "${jsonencode(data.kubernetes_secret.postgres_secret.data)}"
  filename = "${local.credentials_file}"
  depends_on = ["null_resource.deploy_postgres", "null_resource.create_tmp"]
}

resource "null_resource" "write_hostname" {
  depends_on = ["local_file.write_postgres_credentials"]

  provisioner "local-exec" {
    command = "cat ${local.credentials_file} | sed -E \"s/.*host=([^ ]*).*/\\1/\" > ${local.hostname_file}"
  }
}

resource "null_resource" "write_port" {
  depends_on = ["local_file.write_postgres_credentials"]

  provisioner "local-exec" {
    command = "cat ${local.credentials_file} | sed -E \"s/.*port=([0-9]*).*/\\1/\" > ${local.port_file}"
  }
}

resource "null_resource" "write_username" {
  depends_on = ["local_file.write_postgres_credentials"]

  provisioner "local-exec" {
    command = "cat ${local.credentials_file} | sed -E \"s/.*user=([^ ]*).*/\\1/\" > ${local.username_file}"
  }
}

resource "null_resource" "write_password" {
  depends_on = ["local_file.write_postgres_credentials"]

  provisioner "local-exec" {
    command = "cat ${local.credentials_file} | sed -E \"s/.*PGPASSWORD=([^ ]*).*/\\1/\" > ${local.password_file}"
  }
}

resource "null_resource" "write_dbname" {
  depends_on = ["local_file.write_postgres_credentials"]

  provisioner "local-exec" {
    command = "cat ${local.credentials_file} | sed -E \"s/.*dbname=([^ ]*).*/\\1/\" > ${local.dbname_file}"
  }
}

data "local_file" "username" {
  depends_on = ["null_resource.write_username"]

  filename = "${local.username_file}"
}

data "local_file" "password" {
  depends_on = ["null_resource.write_password"]

  filename = "${local.password_file}"
}

data "local_file" "hostname" {
  depends_on = ["null_resource.write_hostname"]

  filename = "${local.hostname_file}"
}

data "local_file" "port" {
  depends_on = ["null_resource.write_port"]

  filename = "${local.port_file}"
}

data "local_file" "dbname" {
  depends_on = ["null_resource.write_dbname"]

  filename = "${local.dbname_file}"
}
