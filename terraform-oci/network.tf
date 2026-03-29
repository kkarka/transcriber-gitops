# 1. Define where this lives (Using your Root Tenancy as the compartment)
variable "compartment_ocid" {
  description = "The OCID of the compartment"
  type        = string
  default     = "ocid1.tenancy.oc1..aaaaaaaaxkh525vdshlefhy3barfyu2hyqe2txslfwx5ixus77zsbraqmkza" # <--- PASTE YOUR TENANCY OCID HERE
}

# 2. The Main Network (VCN)
resource "oci_core_vcn" "transcriber_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "transcriber-vcn"
  dns_label      = "transcriber"
}

# 3. The Internet Gateway (Allows traffic in and out of the network)
resource "oci_core_internet_gateway" "transcriber_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.transcriber_vcn.id
  display_name   = "transcriber-igw"
  enabled        = true
}

# 4. The Route Table (Directs outbound traffic to the Internet Gateway)
resource "oci_core_default_route_table" "transcriber_route_table" {
  manage_default_resource_id = oci_core_vcn.transcriber_vcn.default_route_table_id

  route_rules {
    network_entity_id = oci_core_internet_gateway.transcriber_igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

# 5. The Subnet (The specific network block where your Kubernetes nodes will live)
resource "oci_core_subnet" "transcriber_public_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.transcriber_vcn.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "transcriber-public-subnet"
  route_table_id    = oci_core_vcn.transcriber_vcn.default_route_table_id
  security_list_ids = [oci_core_vcn.transcriber_vcn.default_security_list_id]
  dns_label         = "public"
}