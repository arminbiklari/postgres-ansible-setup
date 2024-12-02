# resource "postgresql_role" "db_user" {
#   for_each  = { for user in var.postgresql_users : user.name => user }

#   name       = each.value.name
#   password   = each.value.password
#   login      = true
#   create_db  = each.value.privileges.create_db
#   create_role = each.value.privileges.create_role
# }

locals {
  user_privileges = {
    for user in var.postgresql_users : user.name => {
      createdb     = user.privileges.create_db
      createrole   = user.privileges.create_role
      replication  = user.privileges.replication
      superuser    = user.privileges.superuser
    }
  }
}

resource "postgresql_role" "db_user" {
  for_each  = { for user in var.postgresql_users : user.name => user }

  name       = each.value.name
  password   = each.value.password
  login      = true
  create_role = local.user_privileges[each.key].createrole
  replication = local.user_privileges[each.key].replication
  superuser  = local.user_privileges[each.key].superuser
}

# Loop through the postgresql_databases list and create each database
resource "postgresql_database" "db" {
  for_each = { for db in var.postgresql_databases : db.name => db }

  name       = each.value.name
  owner      = each.value.owner
  encoding   = each.value.encoding
  lc_collate = each.value.lc_collate
  lc_ctype   = each.value.lc_ctype
  template   = each.value.template
}
