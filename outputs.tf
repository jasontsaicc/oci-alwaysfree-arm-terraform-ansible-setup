output "instance_public_ip_1" {
  description = "Public IP address of free-arm-vm-1"
  value       = oci_core_instance.arm_vm_1.public_ip
}

output "instance_private_ip_1" {
  description = "Private IP address of free-arm-vm-1"
  value       = oci_core_instance.arm_vm_1.private_ip
}

output "instance_public_ip_2" {
  description = "Public IP address of free-arm-vm-2"
  value       = oci_core_instance.arm_vm_2.public_ip
}

output "instance_private_ip_2" {
  description = "Private IP address of free-arm-vm-2"
  value       = oci_core_instance.arm_vm_2.private_ip
}

output "subnet_ocid" {
  description = "The OCID of the subnet"
  value       = oci_core_subnet.freevm_subnet.id
}
output "vcn_ocid" {
  description = "The OCID of the VCN"
  value       = oci_core_vcn.new_vcn.id
}
output "msg_ocid" {
  description = "The OCID of the NSG"
  value       = oci_core_network_security_group.new_nsg.id
}
