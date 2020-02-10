variable "cluster_type" {
  type        = string
  description = "The type of cluster (openshift or ocp3 or ocp4 or kubernetes)"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group where the cluster has been provisioned."
}

variable "resource_location" {
  type        = string
  description = "Geographic location of the resource (e.g. us-south, us-east)"
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The api key used to access the IBM Cloud resources"
}

variable "cluster_config_file" {
  type        = string
  description = "Cluster config file for Kubernetes cluster."
}

variable "olm_namespace" {
  type        = string
  description = "The namespace where OLM has been deployed"
}

variable "server_url" {
  type        = string
  description = "The namespace where OLM has been deployed"
}

variable "login_user" {
  type        = string
  description = "The namespace where OLM has been deployed"
  default     = "apikey"
}

variable "login_password" {
  type        = string
  description = "The namespace where OLM has been deployed"
}
