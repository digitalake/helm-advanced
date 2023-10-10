data "digitalocean_kubernetes_versions" "this" {
  version_prefix = var.k8s_version_prefix
}

resource "digitalocean_kubernetes_cluster" "this" {
  name         = var.k8s_cluster_name
  region       = var.k8s_cluster_region
  auto_upgrade = var.k8s_cluster_auto_upgrade
  version      = data.digitalocean_kubernetes_versions.this.latest_version

  maintenance_policy {
    start_time = "04:00"
    day        = "sunday"
  }

  node_pool {
    name       = var.k8s_node_pull_name
    size       = var.k8s_node_pull_size
    node_count = var.k8s_node_count
  }
}

resource "local_sensitive_file" "kubeconfig" {
  filename = "${path.module}/.kube/config"
  content  = digitalocean_kubernetes_cluster.this.kube_config[0].raw_config
}