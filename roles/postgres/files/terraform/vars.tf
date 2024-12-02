variable "postgres_root_user" {
  description = "Root PostgreSQL user"
  type        = string
}

variable "postgres_root_password" {
  description = "Root PostgreSQL user password"
  type        = string
}

variable "listen_port" {
  type = number
}

variable "listen_addresses" {
  type = string
}

variable "postgresql_databases" {
  description = "List of PostgreSQL databases to create"
  type = list(object({
    name       = string
    owner      = string
    encoding   = string
    lc_collate = string
    lc_ctype   = string
    template   = string
  }))
}

variable "postgresql_users" {
  description = "List of PostgreSQL users"
  type = list(object({
    name       = string
    password   = string
    privileges = object({
      create_db   = bool
      create_role = bool
      replication = bool
      superuser   = bool
    })
  }))
  # Set default values for postgresql_users
  default = [
    {
      name       = "example"
      password   = "123"
      privileges = {
        create_db   = false
        create_role = false
        replication = false
        superuser   = false
      }
    }
  ]
}
