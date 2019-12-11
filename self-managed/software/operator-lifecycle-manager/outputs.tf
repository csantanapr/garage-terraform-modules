output "namespace" {
  value       = "olm"
  description = "namespace where OLM is running"
  depends_on  = ["null_resource.deploy_operator_lifecycle_manager"]
}
