resource "google_artifact_registry_repository" "lookup_repo" {
  location      = "us-central1"
  repository_id = "my-repository"
  format        = "DOCKER"
  docker_config {
    immutable_tags = true
  }
}