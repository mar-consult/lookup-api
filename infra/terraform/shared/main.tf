resource "google_artifact_registry_repository" "lookup_repo" {
  location      = "us-central1"
  repository_id = "lookup-api"
  format        = "DOCKER"
  docker_config {
    immutable_tags = true
  }
}

module "vpc" {
  source = "../modules/vpc"
  private_subnets = [ {region = "us-central1", cidr_block = "10.0.1.0/24" }]
  public_subnets = [ {region = "us-central1", cidr_block = "10.0.2.0/24" }]
}

resource "google_service_account" "artifact_registry_sa" {
  account_id   = "artifact-registry-sa"
  display_name = "Service Account for Artifact Registry Access"
}

resource "google_artifact_registry_repository_iam_binding" "artifact_registry_binding" {
  repository = google_artifact_registry_repository.lookup_repo.id
  role       = "roles/artifactregistry.writer"
  members = [
    "serviceAccount:${google_service_account.artifact_registry_sa.email}"
  ]
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = data.google_client_config.default.project
  name                       = "gke-1"
  region                     = "us-central1"
  zones                      = ["us-central1-a", "us-central1-b"]
  network                    = module.vpc.name
  subnetwork                 = "private-us-central1"
  ip_range_pods              = "private-us-central1"
  ip_range_services          = "private-us-central1"
  http_load_balancing        = true
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = true
  dns_cache                  = true

  node_pools = [
    {
      name                        = "default-node-pool"
      machine_type                = "e2-medium"
      node_locations              = "us-central1-b,us-central1-c"
      min_count                   = 1
      max_count                   = 10
      local_ssd_count             = 0
      spot                        = false
      disk_size_gb                = 100
      disk_type                   = "pd-standard"
      image_type                  = "COS_CONTAINERD"
      enable_gcfs                 = false
      enable_gvnic                = false
      logging_variant             = "DEFAULT"
      auto_repair                 = true
      auto_upgrade                = true
      service_account             = "serviceAccount:${google_service_account.artifact_registry_sa.email}"
      preemptible                 = false
      initial_node_count          = 3
    },
  ]

  
  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}