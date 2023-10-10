output "k8s_cluster_endpoint" {
  value = digitalocean_kubernetes_cluster.this.endpoint
}

output "k8s_cluster_status" {
  value = digitalocean_kubernetes_cluster.this.status
}

output "k8s_cluster_node_count" {
  value = digitalocean_kubernetes_cluster.this.node_pool[0].actual_node_count
}

