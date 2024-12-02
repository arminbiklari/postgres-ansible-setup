terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.23.0"
    }
  }
}

provider "postgresql" {
  host     = var.listen_addresses        # Host passed from Ansible or defaults
  port     = var.listen_port              # PostgreSQL port
  username = var.postgres_root_user  # Root user (passed via Ansible)
  password = var.postgres_root_password # Root password (passed via Ansible)
  sslmode  = "disable"
}

terraform {
  backend "http" {}
}
