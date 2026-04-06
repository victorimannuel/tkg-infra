#!/bin/bash
set -e

echo "========================================="
echo "   TKG Website Deployment Script"
echo "========================================="

echo ""
echo "[1/2] Building Website..."
cd ../tkg-website
npm run build
cd ../tkg-infra

echo ""
echo "[2/2] Deploying Website to Production (Ansible)"
echo "Note: You will be prompted for your Ansible Vault password below."
make deploy-website

echo ""
echo "========================================="
echo "   Website Deployment Complete!"
echo "========================================="
