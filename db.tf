resource "digitalocean_database_cluster" "this" {
  name       = var.postgres_cluster_name
  engine     = "pg"
  version    = var.postgres_cluster_version
  size       = var.postgres_cluster_size
  region     = var.postgres_cluster_region
  node_count = var.postgres_cluster_node_count
}

resource "digitalocean_database_db" "this" {
  cluster_id = digitalocean_database_cluster.this.id
  name       = var.postgres_cluster_db
}

resource "digitalocean_database_user" "this" {
  cluster_id = digitalocean_database_cluster.this.id
  name       = var.postgres_cluster_user
}

resource "digitalocean_database_firewall" "this" {
  cluster_id = digitalocean_database_cluster.this.id

  rule {
    type  = "k8s"
    value = digitalocean_kubernetes_cluster.this.id
  }
}