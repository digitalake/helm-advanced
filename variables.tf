variable "k8s_version_prefix" {
  type        = string
  description = "A value to get upgrades in num.num. format"
  default     = "1.28."
}

variable "k8s_cluster_name" {
  type        = string
  description = "A name for managed k8s cluster"
  default     = "default"
}

variable "k8s_cluster_region" {
  type        = string
  description = "K8s cluster placement by region"
  default     = "fra1"
}

variable "k8s_cluster_auto_upgrade" {
  type        = bool
  description = "Define if k8s cluster should me upgraded automaticly"
  default     = true
}

variable "k8s_node_pull_name" {
  type        = string
  description = "A name for worker nodes of k8s cluster"
  default     = "default"
}

variable "k8s_node_pull_size" {
  type        = string
  description = "An instance size to use when creating node pull"
  default     = "s-1vcpu-2gb"
}

variable "k8s_node_count" {
  type        = number
  description = "A number of nodes to create"
  default     = 1
}

variable "postgres_cluster_name" {
  type        = string
  description = "A name for postgres DB cluster"
  default     = "postgres-cluster"
}

variable "postgres_cluster_version" {
  type        = string
  description = "A version for postgres DB cluster"
  default     = "12"
}

variable "postgres_cluster_size" {
  type        = string
  description = "DB instance size for postgres DB cluster"
  default     = "db-s-1vcpu-1gb"
}

variable "postgres_cluster_region" {
  type        = string
  description = "DB cluster placement by region"
  default     = "fra1"
}

variable "postgres_cluster_node_count" {
  type        = number
  description = "Node count for the cluster"
  default     = 1
}

variable "postgres_cluster_db" {
  type        = string
  description = "DB to create"
  default     = "django"
}

variable "postgres_cluster_user" {
  type        = string
  description = "DB user to create"
  default     = "django"
}