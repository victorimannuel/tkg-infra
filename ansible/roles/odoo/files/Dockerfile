FROM odoo:19.0

USER root

# Install extra system dependencies if needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    libldap2-dev \
    libsasl2-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy external addons (OCA and third-party)
COPY --chown=odoo:odoo external-addons/ /mnt/external-addons/

# Copy custom addons (tara_gym, bvc_invoice, etc.)
COPY --chown=odoo:odoo custom-addons/ /mnt/custom-addons/

# Install any extra Python requirements (add requirements.txt if needed)
# COPY requirements.txt /tmp/requirements.txt
# RUN pip install --no-cache-dir -r /tmp/requirements.txt

USER odoo
