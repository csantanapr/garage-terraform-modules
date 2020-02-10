output "namespace" {
  value       = local.namespace
  description = "namespace where the operator is running"
  depends_on  = [null_resource.deploy_cloud_operator]
}
