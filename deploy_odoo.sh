#!/bin/bash
set -e

echo "========================================="
echo "   TKG Odoo Deployment Script"
echo "========================================="

echo ""
echo "[1/2] Preparing Odoo Addons..."
make prepare-addons

echo ""
echo "[2/2] Deploying Odoo to Production (Ansible)"
if [ -f ".vault_pass" ]; then
  echo "Using vault password file: .vault_pass"
else
  echo "Vault password file not found (.vault_pass). You will be prompted."
fi
make deploy-odoo

echo ""
echo "========================================="
echo "   Odoo Deployment Complete!"
echo "========================================="
