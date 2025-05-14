terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.35.0"
    }
  }

  backend "gcs" {
        bucket = "lookup-api-state"
        prefix  = "shared/terraform.tfstate" # Optional: Specify a path within the bucket
        region  = "us-central1"
        # Optional: Specify your service account credentials if needed
        # Use the following if you are not using the gcloud credentials
        # service_account_email = "your-service-account-email@your-project.iam.gserviceaccount.com"
        # key_file = "path/to/your/key.json"
    }
}

provider "google" {
  project     = "playground-s-11-38cb6692"
  region      = "us-central1"
}
