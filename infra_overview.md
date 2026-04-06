# TKG Corporate Infrastructure — Overview

This repository (`tkg-infra`) manages the automated deployment and orchestration for the **PT Tara Kencana Group** ecosystem.

## 🏗️ Architecture Stack
- **OS**: Ubuntu Linux
- **Proxy/Web**: Nginx (Host-level)
- **SSL**: Let's Encrypt (Certbot)
- **App 1**: Static Website (React/Vite) — Served directly by Nginx
- **App 2**: Odoo 19.0 (ERP) — Running in **Docker Containers**
- **DB**: PostgreSQL — Running in **Docker Containers**
- **Automation**: **Ansible** (Playbook & Roles)

## 🌐 Domains
| Service | URL | Path (on server) |
|---|---|---|
| **Main Website** | `tarakencanagroup.com` | `/var/www/tkg-website` |
| **Odoo System** | `odoo.tarakencanagroup.com` | `/opt/odoo` |

## 🛠️ Management Commands (via Makefile)
Run these from the `tkg-infra` root:

| Command | Purpose |
|---|---|
| `make deploy-website` | Update/Sync the static website content. |
| `make deploy-odoo` | Update Odoo code, addons, and containers. |
| `make deploy-nginx` | Update Nginx config or add SSL for new domains. |
| `make deploy` | **Full maintenance**: Sync everything (Odoo + Web + Nginx). |
| `make ping` | Check connection to the server. |

## 📁 Key Files
- `ansible/group_vars/all/vars.yml`: Configuration for domains, filters, and SSH user.
- `ansible/group_vars/all/vault.yml`: Encrypted secrets (passwords).
- `ansible/inventory/hosts.yml`: Server IP and SSH credentials.
- `ansible/roles/`: Individual automation scripts (nginx, odoo, website, docker).

---
*Infrastructure is now operational. Use the Makefile commands for daily management.*
