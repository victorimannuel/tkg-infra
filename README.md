# Odoo TKG — Deployment Guide

Deploy Odoo 19 CE (TKG) ke Ubuntu 24.04 server menggunakan Docker + Ansible + Nginx + SSL.

## Arsitektur

```
Internet → Nginx (443 HTTPS / Let's Encrypt)
               └→ Odoo Container (:8069, :8072)
                      └→ PostgreSQL 16 Container
                              └→ Docker Volume (data)

Cron (02:00 WIB) → backup.sh → pg_dump + filestore → rclone → Google Drive
```

## Prerequisites

Di **local machine**:
- Ansible: `pip install ansible ansible-lint`
- Ansible collections: `ansible-galaxy collection install community.general community.docker ansible.posix`
- SSH key sudah di-setup ke server target

Di **server**:
- Ubuntu 24.04 LTS (fresh/minimal install)
- SSH access sebagai `ubuntu` (atau user dengan sudo)
- Port 22, 80, 443 terbuka di firewall cloud provider

---

## Setup Sebelum Deploy

### 1. Edit Inventory
Buka `ansible/inventory/hosts.yml`, isi IP server dan path SSH key:
```yaml
ansible_host: 123.45.67.89
ansible_user: ubuntu
ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### 2. Edit Variables
Buka `ansible/group_vars/all.yml`, isi domain, passwords, dll:
```yaml
odoo_domain: "gym.yourdomain.com"
ssl_email: "admin@yourdomain.com"
odoo_admin_passwd: "strong-admin-password"
postgres_password: "strong-db-password"
```

> ⚠️ **PASTIKAN domain sudah pointing ke IP server sebelum deploy** (DNS A record harus sudah aktif untuk Let's Encrypt)

### 3. Setup Google Drive Backup (rclone)

Di local machine:
```bash
# Install rclone
curl https://rclone.org/install.sh | sudo bash

# Setup Google Drive remote (ikuti wizard interaktif)
rclone config
# Buat remote baru → pilih "Google Drive" → nama: gdrive
# Setelah selesai:
cat ~/.config/rclone/rclone.conf
```
Copy isi file tersebut ke `ansible/roles/backup/files/rclone.conf`

### 4. Siapkan Addons

Struktur yang dibutuhkan di folder `tkg-infra/`:
```
tkg-infra/
├── addons/               ← Symlinks ke ../tkg-odoo/addons/
├── external-addons/      ← Symlinks ke ../tkg-odoo/external-addons/
├── ansible/
└── Makefile
```

Jalankan script symlink helper:
```bash
# Dari folder tkg-infra/
make prepare-addons
```

---

## Deploy

### Deploy Pertama Kali (Full Stack)
```bash
# Dari folder deployment/
make deploy

# Atau manual:
cd ansible
ansible-playbook -i inventory/hosts.yml playbook.yml
```

### Deploy Hanya Odoo (Update Addons)
```bash
make deploy-odoo

# Atau manual:
ansible-playbook -i inventory/hosts.yml playbook.yml --tags odoo
```

### Deploy Hanya Nginx/SSL
```bash
ansible-playbook -i inventory/hosts.yml playbook.yml --tags nginx
```

### Dry Run (Preview tanpa apply)
```bash
make dry-run
```

---

## Update Custom Addons

Setelah edit custom addon di local:
```bash
make deploy-odoo
```
Ansible akan rsync addons ke server, rebuild Docker image jika perlu, dan restart Odoo.

---

## Backup Manual

```bash
# SSH ke server dulu
ssh ubuntu@your-server-ip

# Jalankan backup manual
sudo /opt/odoo/backup.sh

# Lihat log backup
tail -f /var/log/odoo/backup.log

# Cek file di Google Drive
rclone ls gdrive:OdooTKG-Backups/
```

---

## Restore Database

```bash
# 1. Download backup dari Google Drive
rclone copy "gdrive:OdooTKG-Backups/daily/YYYYMMDD_HHMMSS/" /tmp/restore/

# 2. Stop Odoo
cd /opt/odoo && docker compose stop odoo

# 3. Drop existing DB dan restore
gunzip -c /tmp/restore/db_odoo_tkg_*.sql.gz | \
  docker exec -i odoo_postgres psql -U odoo -d postgres -c "DROP DATABASE IF EXISTS odoo_tkg;" && \
  docker exec -i odoo_postgres createdb -U odoo odoo_tkg && \
  gunzip -c /tmp/restore/db_odoo_tkg_*.sql.gz | docker exec -i odoo_postgres psql -U odoo odoo_tkg

# 4. Restore filestore
docker run --rm \
  -v odoo_odoo-data:/data \
  -v /tmp/restore:/backup:ro \
  busybox tar xzf /backup/filestore_*.tar.gz -C /data

# 5. Start Odoo
docker compose start odoo
```

---

## Maintenance Commands

```bash
# Lihat logs Odoo
docker logs odoo_app -f --tail=100

# Lihat logs Nginx
sudo tail -f /var/log/nginx/odoo.error.log

# Restart Odoo saja
cd /opt/odoo && docker compose restart odoo

# Restart semua
cd /opt/odoo && docker compose restart

# PostgreSQL shell
docker exec -it odoo_postgres psql -U odoo odoo_tkg
```

---

## Struktur Direktori di Server

```
/opt/odoo/
├── docker-compose.yml
├── odoo.conf
├── Dockerfile
├── backup.sh
├── custom-addons/
└── external-addons/

/var/log/odoo/
├── odoo.log
└── backup.log
```
