provider "harbor" {
  #url = "https://.../" # also env HARBOR_URL 
  #username = "admin" # also env HARBOR_USERNAME
  #password = "..." # also env HARBOR_PASSWORD
}

# ----------------------------------------------------------------------------------------------------------------------
#### A simple project to push to, public read, and a robot account to push.
# ----------------------------------------------------------------------------------------------------------------------
resource "harbor_project" "project-test" {
  name                   = "test"
  public = true # can be pulled by unauthenticated
  vulnerability_scanning = true
  force_destroy          = true # allow deletion of images when deleting the project
}

variable "robot_password" {
  # TF_VAR_robot_password environment variable/secret to set this
  type      = string
  sensitive = true
}

resource "harbor_robot_account" "project-test-robot-account-pusher" {
  name = "pusher" # docker login '--username=robot$test+pusher' '--password=xxxx' harbor.xxx.com
  description = "project level robot account"
  secret = var.robot_password # 1 upper, 1 lower, 1 number and 1 special and at least 8 chars required
  level       = "project"
  permissions {
    access {
      action   = "pull"
      resource = "repository"
    }
    access {
      action   = "push"
      resource = "repository"
    }
    kind      = "project"
    namespace = harbor_project.project-test.name
  }
}

# ----------------------------------------------------------------------------------------------------------------------
### Proxy to ghcr.io; public.
# ----------------------------------------------------------------------------------------------------------------------
# https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/registry
resource "harbor_registry" "ghcr_proxy_registry" {
  provider_name = "github"
  name          = "ghcr.io"
  endpoint_url  = "https://ghcr.io"
  description   = "GitHub Container Registry ghcr.io Proxy created via Terraform"
}

resource "harbor_project" "main" {
  name                   = "ghcr.io"
  registry_id            = harbor_registry.ghcr_proxy_registry.registry_id
  public = true # anyone can access
  force_destroy = true # allow deletion of images when deleting the project
  vulnerability_scanning = false # no vuln scanning
} 
# ----------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------
### Proxy to docker.io; public.
# ----------------------------------------------------------------------------------------------------------------------
# https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/registry
resource "harbor_registry" "docker_proxy_registry" {
  provider_name = "docker-hub"
  name          = "docker.io"
  endpoint_url  = "https://hub.docker.com"
  description   = "Docker Hub docker.io Proxy created via Terraform"
}

resource "harbor_project" "docker" {
  name          = "docker.io"
  registry_id   = harbor_registry.docker_proxy_registry.registry_id
  vulnerability_scanning = false # no vuln scanning
  public = true # anyone can access
  force_destroy = true # allow deletion of images when deleting the project
}

# ----------------------------------------------------------------------------------------------------------------------
### Proxy to quay.io; public.
# ----------------------------------------------------------------------------------------------------------------------
# https://registry.terraform.io/providers/goharbor/harbor/latest/docs/resources/registry
resource "harbor_registry" "quay_proxy_registry" {
  provider_name = "quay"
  name          = "quay.io"
  endpoint_url  = "https://quay.io"
  description   = "Quay Container Registry quay.io Proxy created via Terraform"
}

resource "harbor_project" "quay" {
  name          = "quay.io"
  registry_id   = harbor_registry.quay_proxy_registry.registry_id
  vulnerability_scanning = false # no vuln scanning
  public = true # anyone can access
  force_destroy = true # allow deletion of images when deleting the project
}
