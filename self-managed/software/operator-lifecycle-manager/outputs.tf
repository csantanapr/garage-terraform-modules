output "namespace" {
  value       = local.operator_namespace
  description = "namespace where OLM is running"
  depends_on  = [null_resource.deploy_operator_lifecycle_manager]
}
