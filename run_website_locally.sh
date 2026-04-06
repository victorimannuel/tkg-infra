#!/bin/bash
set -e

echo "========================================="
echo "   TKG Website Running Script"
echo "========================================="

echo ""
echo "Running Website..."
cd ../tkg-website
npm run dev

echo ""
echo "========================================="
echo "		  Website Running!"
echo "========================================="
