ANSIBLE_DIR = ansible
INVENTORY   = $(ANSIBLE_DIR)/inventory/hosts.yml
PLAYBOOK    = $(ANSIBLE_DIR)/playbook.yml
INFRA_DIR   := $(CURDIR)
VAULT_PASS_FILE ?= $(INFRA_DIR)/.vault_pass

ifneq ($(wildcard $(VAULT_PASS_FILE)),)
VAULT_FLAGS = --vault-password-file $(VAULT_PASS_FILE)
else
VAULT_FLAGS = --ask-vault-pass
endif

.PHONY: help prepare-addons deploy deploy-odoo deploy-nginx init-db dry-run ping

help:
	@echo ""
	@echo "  Odoo TKG Deployment Helper"
	@echo "  ─────────────────────────"
	@echo "  make prepare-addons  — Symlink addons from project to deployment/"
	@echo "  make deploy          — Full deploy (all roles)"
	@echo "  make deploy-odoo     — Deploy/update Odoo & addons only"
	@echo "  make deploy-website  — Deploy/update Static Website only"
	@echo "  make deploy-nginx    — Deploy/update Nginx & SSL only"
	@echo "  make init-db         — Initialize Odoo database (first run only)"
	@echo "  make dry-run         — Preview changes (no apply)"
	@echo "  make ping            — Test Ansible connectivity"
	@echo "  Vault pass source    — $(VAULT_PASS_FILE) if present, otherwise prompt"
	@echo ""

prepare-addons:
	@echo "Symlinking addons..."
	@mkdir -p addons external-addons
	@ln -sfn ../../tkg-odoo/addons/tara_gym            addons/tara_gym
	@ln -sfn ../../tkg-odoo/addons/bvc_invoice         addons/bvc_invoice
	@ln -sfn ../../tkg-odoo/addons/sale_referrer_credit addons/sale_referrer_credit
	@ln -sfn ../../tkg-odoo/addons/tara_gym_gymmaster   addons/tara_gym_gymmaster
	@for addon in ../tkg-odoo/external-addons/*; do \
		if [ -d "$$addon" ]; then \
			ln -sfn "../../tkg-odoo/external-addons/$$(basename "$$addon")" "external-addons/$$(basename "$$addon")"; \
		fi \
	done
	@echo "Done! Check addons/ and external-addons/ directories."

deploy:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.yml playbook.yml $(VAULT_FLAGS)

deploy-odoo:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.yml playbook.yml --tags odoo $(VAULT_FLAGS)

deploy-website:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.yml playbook.yml --tags website $(VAULT_FLAGS)

deploy-nginx:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.yml playbook.yml --tags nginx,ssl $(VAULT_FLAGS)

init-db:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.yml playbook.yml --tags init-db $(VAULT_FLAGS)

dry-run:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.yml playbook.yml --check --diff

ping:
	cd $(ANSIBLE_DIR) && ansible all -i inventory/hosts.yml -m ping
