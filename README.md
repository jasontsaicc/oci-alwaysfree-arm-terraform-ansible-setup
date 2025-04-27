# OCI Always Free ARM VM Setup (Terraform + Ansible)

Automate the creation and security hardening of **Oracle Cloud Always Free ARM VMs**.

##  Project Structure
```
.
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
├── ansible/
│   ├── inventory.ini
│   ├── setup-basic.yaml
│   └── install-docker.yaml
└── README.md
```

##  Components
- **Terraform**: 
  - Deploys two Ubuntu ARM VMs
  - Assigns public IPs
  - Prepares SSH access
- **Ansible**:
  - Updates packages, installs base tools
  - Configures NTP with Google servers
  - Secures SSH with `firewalld` and `fail2ban`
  - Installs Docker Engine and Docker Compose

##  How to Use

### 1. Prepare your environment
- Terraform installed (`>=1.3`)
- Ansible installed (`>=2.10`)
- OCI CLI configured, or have your `tenancy_id`, `compartment_id`, `ssh_public_key`, etc.

### 2. Deploy with Terraform
```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

**After apply**, get the public IPs:
```bash
terraform output instance_public_ip_1
terraform output instance_public_ip_2
```
Fill these into `ansible/inventory.ini`.

### 3. Setup the VMs with Ansible
```bash
cd ansible/
ansible-playbook -i inventory.ini setup-basic.yaml
ansible-playbook -i inventory.ini install-docker.yaml
```

## ⚡ Tips
- Always validate security rules (`Security Lists`, `NSG`) to allow SSH and ICMP.
- Always validate NTP settings (especially if strict clock drift control needed).

## TODO / Improvements
- [ ] Use **dynamic Ansible inventory** (parse `terraform output` JSON)
- [ ] Modularize Terraform: separate `vcn`, `subnet`, `instances` into modules
- [ ] Harden `firewalld` and allow only necessary ports
- [ ] Optional: install monitoring agent (e.g., `prometheus-node-exporter`)
- [ ] Add basic output: username/password auto-generation (currently manual)

---
