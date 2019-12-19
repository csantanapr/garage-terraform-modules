output "namespace" {
  value       = "${var.namespace}"
  description = "Namespace of the postgres operator"
  depends_on  = ["null_resource.deploy_postgres"]
}
