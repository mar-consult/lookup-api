terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.35.0"
    }
  }

  backend "gcs" {
    bucket = "lookup-api-state"
    prefix = "shared/terraform.tfstate"
  }
}

provider "google" {
  project = "playground-s-11-38cb6692"
  region  = "us-central1"
}
