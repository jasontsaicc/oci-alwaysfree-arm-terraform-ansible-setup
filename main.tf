provider "oci" {
  region = var.region
}

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
    display_name     = "free-arm-vnic-1"
    hostname_label   = "freearmvm-1"
  }

  source_details {
    source_type = "image"
    source_id    = var.image_ocid
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  preserve_boot_volume = false
}

resource "oci_core_instance" "arm_vm_2" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "free-arm-vm-2"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    assign_public_ip = true
    display_name     = "free-arm-vnic-2"
    hostname_label   = "freearmvm-2"
  }

  source_details {
    source_type = "image"
    source_id   = var.image_ocid
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  preserve_boot_volume = false
}

