## This file is NOT included in the GitOps deployment (see .helmignore); it is for local development only.

terraform {
  required_providers {
    harbor = {
      source  = "goharbor/harbor"
      version = "3.10.16"
    }
  }
  required_version = ">= 1.6.0"

  # Store state in k8s Secret; limited to 1MB, don't go crazy; it is gzipped.
  backend "kubernetes" {
    in_cluster_config = true
    secret_suffix     = "harbortf"
    namespace         = "harbor" # this must pre-exist, of course
  }
  #backend "pg" {
  #  # This is configured via PGHOST et al: https://www.postgresql.org/docs/current/libpq-envars.html
  #}
}
