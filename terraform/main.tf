terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = ">= 4.0.0"
    }
  }
}

# 1) 建立共用的 Network Security Group

resource "oci_core_network_security_group" "shared_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_ocid        # 你要放在哪個 VCN 底下，請替換成實際變數
  display_name   = var.nsg_display_name
}
# 範例：在 NSG 裡允許 HTTP (80) 及 SSH (22) Ingress，和所有 Egress
# SSH ingress rules - dynamic based on ssh_allowed_cidrs variable
resource "oci_core_network_security_group_security_rule" "allow_ssh" {
  count                     = length(var.ssh_allowed_cidrs)
  network_security_group_id = oci_core_network_security_group.shared_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = var.ssh_allowed_cidrs[count.index]
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
  description = "Allow SSH from ${var.ssh_allowed_cidrs[count.index]}"
}

# Administrative SSH ingress rules - separate rules for admin access if specified
resource "oci_core_network_security_group_security_rule" "allow_admin_ssh" {
  count                     = length(var.admin_ssh_cidrs)
  network_security_group_id = oci_core_network_security_group.shared_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = var.admin_ssh_cidrs[count.index]
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
  description = "Allow administrative SSH from ${var.admin_ssh_cidrs[count.index]}"
}

# HTTPS ingress rule
resource "oci_core_network_security_group_security_rule" "allow_http" {
  network_security_group_id = oci_core_network_security_group.shared_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
  description = "Allow HTTP from anywhere"
}
resource "oci_core_network_security_group_security_rule" "allow_http_port_80" {
  network_security_group_id = oci_core_network_security_group.shared_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
  description = "Allow HTTP (80) for ingress controller"
}
# wireguard ingress rule
resource "oci_core_network_security_group_security_rule" "allow_wireguard" {
  network_security_group_id = oci_core_network_security_group.shared_nsg.id
  direction                 = "INGRESS"
  protocol                  = "17" # UDP
  source                    = "0.0.0.0/0"
  udp_options {
    destination_port_range {
      min = 16390
      max = 16390
    }
  }
  description = "Allow HTTP from anywhere"
}
# ICMP ingress rule
resource "oci_core_network_security_group_security_rule" "allow_icmp" {
  network_security_group_id = oci_core_network_security_group.shared_nsg.id
  direction                 = "INGRESS"
  protocol                  = "1" # ICMP
  source                    = "10.0.0.0/8" # 允許來自 VCN 的 ICMP 流量
  icmp_options {
    type = 8 # Echo Request
    code = 0 # Any code
  }
  description = "Allow ICMP from VCN"
}
# allow all traffic from the same NSG
resource "oci_core_network_security_group_security_rule" "allow_internal_traffic" {
  network_security_group_id = oci_core_network_security_group.shared_nsg.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = "10.0.0.0/8"
  description               = "Allow all traffic from the same NSG"
}

# K3s API server (6443/tcp) - for kubectl / K3s agent join
resource "oci_core_network_security_group_security_rule" "allow_k3s_api" {
  network_security_group_id = oci_core_network_security_group.shared_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "10.0.0.0/8"
  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
  description = "Allow Kubernetes API Server (6443)"
}

# K3s agent 連線至 server（9345/tcp）
resource "oci_core_network_security_group_security_rule" "allow_k3s_agent" {
  network_security_group_id = oci_core_network_security_group.shared_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "10.0.0.0/8"
  tcp_options {
    destination_port_range {
      min = 9345
      max = 9345
    }
  }
  description = "Allow K3s agent join (9345)"
}

# Kubelet metrics（10250/tcp）
resource "oci_core_network_security_group_security_rule" "allow_kubelet_metrics" {
  network_security_group_id = oci_core_network_security_group.shared_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "10.0.0.0/8"
  tcp_options {
    destination_port_range {
      min = 10250
      max = 10250
    }
  }
  description = "Allow Kubelet metrics (10250)"
}

# Flannel VXLAN（8472/udp）- 若使用 Flannel CNI
resource "oci_core_network_security_group_security_rule" "allow_flannel_vxlan" {
  network_security_group_id = oci_core_network_security_group.shared_nsg.id
  direction                 = "INGRESS"
  protocol                  = "17" # UDP
  source                    = "10.0.0.0/8"
  udp_options {
    destination_port_range {
      min = 8472
      max = 8472
    }
  }
  description = "Allow Flannel VXLAN (8472)"
}

# NodePort range（30000~32767/tcp）- 外部服務對應端口
resource "oci_core_network_security_group_security_rule" "allow_nodeport_range" {
  network_security_group_id = oci_core_network_security_group.shared_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "10.0.0.0/8"
  tcp_options {
    destination_port_range {
      min = 30000
      max = 32767
    }
  }
  description = "Allow NodePort service range (30000-32767)"
}

# Egress: allow all outbound traffic
resource "oci_core_network_security_group_security_rule" "allow_all_egress" {
  network_security_group_id = oci_core_network_security_group.shared_nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  description               = "Allow all outbound traffic"
}



# 2) 如果需要 Data Volume，先建立 Volume 再掛到 VM

# 第一臺 VM
resource "oci_core_instance" "arm_vm_1" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "free-arm-vm-1"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    assign_public_ip = true
    display_name     = "${var.vm1_display_name}-vnic"
    hostname_label   = var.vm1_hostname_label
    private_ip      = var.vm1_private_ip 

    # 把 VM1 的 VNIC 指定到同一個 NSG
    nsg_ids = [oci_core_network_security_group.shared_nsg.id]

  }

  source_details {
    source_type = "image"
    source_id   = var.image_ocid
    boot_volume_size_in_gbs  = var.boot_volume_size_in_gbs

  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  preserve_boot_volume = false
}

resource "oci_core_instance" "arm_vm_2" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = var.vm2_display_name
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    assign_public_ip = true
    display_name     = "${var.vm2_display_name}-vnic"
    hostname_label   = var.vm2_hostname_label
    private_ip      = var.vm2_private_ip 
    nsg_ids = [oci_core_network_security_group.shared_nsg.id]
  }

  source_details {
    source_type = "image"
    source_id   = var.image_ocid
    boot_volume_size_in_gbs  = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  preserve_boot_volume = false
}

