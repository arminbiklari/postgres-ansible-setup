# postgres-ansible-setup
An Ansible for installing and configure postgresql and terraform for user and database management

# Postgres Ansible Setup

Welcome to the **Postgres Ansible Setup** repository! This project integrates **Ansible** and **Terraform** to streamline the installation, configuration, and management of PostgreSQL. It includes features for database and user creation, configuration updates, and backup/restore operations.

Repository URL: [https://github.com/arminbiklari/postgres-ansible-setup](https://github.com/arminbiklari/postgres-ansible-setup)

## Features
- Automates PostgreSQL installation and configuration using Ansible.
- Database and user management via Terraform.
- Configurable PostgreSQL settings, including `pg_hba.conf` and `postgresql.conf`.
- S3 integration for backups and restores.
- Easy-to-use backup and restore mechanisms.

## Prerequisites
- **Ansible** installed on your control node.
- **Terraform** installed on your local machine.
- Access to an S3 bucket for backup and restore (if applicable).
- Target servers running a supported Linux distribution (e.g., Ubuntu).

---

## Usage Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/arminbiklari/postgres-ansible-setup.git
cd postgres-ansible-setup
```

### 2. How to run ansible playbook

```bash
ansible-playbook --diff -i inventory site.yaml -t postgres --limit <host of postgres> -vvv 
```
and after installation use blow to create databases and users:

```bash
ansible-playbook --diff -i inventory site.yaml -t postgres-mgmt --limit  <host of postgres> -vv
```

## Backup and restore
In default behavior, if run without any input vars, backup creates from all databases on postgres instance and store on s3. for now, restore just support latest backup.

For create backup:
```bash
ansible-playbook --diff -i inventory site.yaml -t postgres-backup --limit  <host of postgres> -vv create_backups=true
```
For restore:
```bash
ansible-playbook --diff -i inventory site.yaml -t postgres-backup --limit  <host of postgres> -vv restore=true
```

## Change Configuration 
### s3 setup 
```yaml
backup:
  s3_backup_dir: /tmp/pg_backups # The path on pg host to keep backups temporary
  s3:
    endpoint: s3-endpoint
    bucket: backups
    secret_key: ChangeMe
    access_key: ChangeMe
```

### User and Database

```yaml
postgres_root_user: postgres
postgres_root_password: "ChangeMe"

postgres_users_no_log: true
postgresql_users: # It is a list of user 
  - name: example
    password: "ChangeMe"
    privileges:
      create_db: true
      create_role: true
      replication: false
      superuser: false

postgresql_databases: # It is a list of database
  - name: kong
    owner: kong
    encoding: "UTF8"
    lc_collate: "en_US.UTF-8"
    lc_ctype: "en_US.UTF-8"
    template: "template0"

```

### PG configs

```yaml
postgresql_locales:
  - 'en_US.UTF-8'
postgresql_auth_method: "{{ ansible_fips  | ternary('scram-sha-256', 'md5') }}"
postgresql_hba_entries:
  - {type: local, database: all, user: postgres, auth_method: peer}
  - {type: local, database: all, user: all, auth_method: peer}
  - {type: host, database: all, user: all, address: '0.0.0.0/0', auth_method: "{{ postgresql_auth_method }}"}
  - {type: host, database: all, user: all, address: '::1/128', auth_method: "{{ postgresql_auth_method }}"}

listen_addresses: "*"
listen_port: "5432"

postgresql_global_config_options: ## Postgresql.conf you can add any postgres configs in key value format
  - option: unix_socket_directories
    value: '{{ postgresql_unix_socket_directories | join(",") }}'
  - option: log_directory
    value: 'log'
  - option: max_connections
    value: '400'
  - option: listen_addresses
    value: "{{ listen_addresses }}"
  - option: port
    value: "{{ listen_port }}"
```