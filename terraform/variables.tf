# variables.tf
variable "region" {
  description = "Oracle Cloud Infrastructure 的 Region"
  type        = string
}
variable "vcn_ocid" {
  description = "要放在哪個 VCN 底下，請替換成實際變數"
  type        = string
  
  validation {
    condition = can(regex("^ocid1\\.vcn\\.", var.vcn_ocid))
    error_message = "The vcn_ocid must be a valid OCI VCN OCID starting with 'ocid1.vcn.'."
  }
}
variable "compartment_ocid" {
  description = "Compartment OCID where resources will be created"
  type        = string
  
  validation {
    condition = can(regex("^ocid1\\.tenancy\\.", var.compartment_ocid))
    error_message = "The compartment_ocid must be a valid OCI Compartment OCID starting with 'ocid1.compartment.'."
  }
}

variable "availability_domain" {
  description = "要放在哪個 Availability Domain，例如 'Uocm:AP-TPE-AD-1'"
  type        = string
}

variable "subnet_ocid" {
  description = "VM VNIC 要放入的 Subnet OCID"
  type        = string
  
  validation {
    condition = can(regex("^ocid1\\.subnet\\.", var.subnet_ocid))
    error_message = "The subnet_ocid must be a valid OCI Subnet OCID starting with 'ocid1.subnet.'."
  }
}

variable "ssh_public_key" {
  description = "用來放到 metadata 裡的 SSH 公鑰內容（一整行）"
  type        = string
}

variable "image_ocid" {
  description = "要用的 Image OCID，例如 Oracle 提供的 Ubuntu 24.04 映像"
  type        = string
  
  validation {
    condition = can(regex("^ocid1\\.image\\.", var.image_ocid))
    error_message = "The image_ocid must be a valid OCI Image OCID starting with 'ocid1.image.'."
  }
}

# Boot Volume 大小（GB），預設 50GB，可透過 CLI/terraform.tfvars 覆蓋
variable "boot_volume_size_in_gbs" {
  description = "Boot Volume size"
  type        = number
  default     = 50
}

# Data Volume（額外掛載磁碟）是否要使用，以及大小
variable "attach_data_volume" {
  description = "是否要建立並 attach 一個額外的 Data Volume"
  type        = bool
  default     = false
}

# NSG 的 display name
variable "nsg_display_name" {
  description = "要建立的 Network Security Group 名稱"
  type        = string
  default     = "shared-vm-nsg"
}

# VM 1 跟 VM 2 的顯示名稱，也可改成變數
variable "vm1_display_name" {
  description = "第一臺 VM 的顯示名稱"
  type        = string
  default     = "free-arm-vm-1"
}

variable "vm2_display_name" {
  description = "第二臺 VM 的顯示名稱"
  type        = string
  default     = "free-arm-vm-2"
}

variable "vm1_hostname_label" {
  type        = string
  default     = "JasonArmVM1"
}

variable "vm2_hostname_label" {
  type        = string
  default     = "JasonArmVM2"
}

variable "vm1_private_ip" {
  description = "Private IP address for VM1 within the subnet"
  type        = string
  
  validation {
    condition = can(cidrhost("${var.vm1_private_ip}/32", 0))
    error_message = "The vm1_private_ip must be a valid IPv4 address (e.g., '10.0.1.10')."
  }
}

variable "vm2_private_ip" {
  description = "Private IP address for VM2 within the subnet"
  type        = string
  
  validation {
    condition = can(cidrhost("${var.vm2_private_ip}/32", 0))
    error_message = "The vm2_private_ip must be a valid IPv4 address (e.g., '10.0.1.11')."
  }
}

# SSH Access Control Variables
variable "ssh_allowed_cidrs" {
  description = "List of CIDR blocks allowed for SSH access to instances. Replace hardcoded IPs with configurable access control."
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for cidr in var.ssh_allowed_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All values in ssh_allowed_cidrs must be valid CIDR blocks (e.g., '192.168.1.0/24', '10.0.0.1/32')."
  }
  
  validation {
    condition = length(var.ssh_allowed_cidrs) > 0
    error_message = "At least one CIDR block must be specified in ssh_allowed_cidrs."
  }
  
  validation {
    condition = alltrue([
      for cidr in var.ssh_allowed_cidrs : !can(regex("^0\\.0\\.0\\.0/0$", cidr)) || length(var.ssh_allowed_cidrs) == 1
    ])
    error_message = "If using 0.0.0.0/0 (allow all), it should be the only CIDR block specified for security clarity."
  }
}

variable "admin_ssh_cidrs" {
  description = "List of CIDR blocks for administrative SSH access. If specified, creates separate admin SSH rules with more restrictive access."
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for cidr in var.admin_ssh_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All values in admin_ssh_cidrs must be valid CIDR blocks (e.g., '192.168.1.0/24', '10.0.0.1/32')."
  }
  
  validation {
    condition = !contains(var.admin_ssh_cidrs, "0.0.0.0/0")
    error_message = "Administrative SSH access should not allow 0.0.0.0/0. Use specific CIDR blocks for enhanced security."
  }
}