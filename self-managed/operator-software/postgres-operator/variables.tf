variable "cluster_type" {
  type        = string
  description = "The type of cluster (kubernetes or openshift or ocp3 or ocp4)"
}

variable "olm_namespace" {
  type        = string
  description = "The namespace where OLM has been deployed"
}

variable "namespace" {
  type        = string
  description = "The namespace where the postgress operator will be deployed"
  default     = "operators"
}

variable "cluster_config_file" {
  type        = string
  description = "Cluster config file for Kubernetes cluster."
}
