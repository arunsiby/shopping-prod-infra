provider "aws" {
  default_tags {
    tags = {
      "project" = var.project_name
      "env"     = var.project_env
    }
  }
}
