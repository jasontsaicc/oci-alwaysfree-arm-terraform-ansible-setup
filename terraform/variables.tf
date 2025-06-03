# variables.tf
variable "region" {
  description = "Oracle Cloud Infrastructure 的 Region"
  type        = string
}
variable "vcn_ocid" {
  description = "要放在哪個 VCN 底下，請替換成實際變數"
  type        = string
}
variable "compartment_ocid" {
  description = "要建立資源的 Compartment OCID"
  type        = string
}

variable "availability_domain" {
  description = "要放在哪個 Availability Domain，例如 'Uocm:AP-TPE-AD-1'"
  type        = string
}

variable "subnet_ocid" {
  description = "VM VNIC 要放入的 Subnet OCID"
  type        = string
}

variable "ssh_public_key" {
  description = "用來放到 metadata 裡的 SSH 公鑰內容（一整行）"
  type        = string
}

variable "image_ocid" {
  description = "要用的 Image OCID，例如 Oracle 提供的 Ubuntu 24.04 映像"
  type        = string
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
  type        = string
}
variable "vm2_private_ip" {
  type        = string
}