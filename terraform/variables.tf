variable "compartment_ocid" {}
variable "availability_domain" {}
variable "subnet_ocid" {}
variable "ssh_public_key" {}
variable "region" {}
variable "image_ocid" {
  description = "The OCID of the image to use for the instance"
  type        = string
}
