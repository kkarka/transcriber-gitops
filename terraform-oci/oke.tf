data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_containerengine_cluster_option" "oke_cluster_option" {
  cluster_option_id = "all"
}

data "oci_containerengine_node_pool_option" "oke_node_pool_option" {
  node_pool_option_id = "all"
}

locals {
  latest_k8s_version = element(reverse(sort(data.oci_containerengine_cluster_option.oke_cluster_option.kubernetes_versions)), 0)

  arm_images = [
    for source in data.oci_containerengine_node_pool_option.oke_node_pool_option.sources : 
    source.image_id 
    if length(regexall("OKE", source.source_name)) > 0 && 
       length(regexall("aarch64", source.source_name)) > 0 && 
       length(regexall("Oracle-Linux-8", source.source_name)) > 0
  ]
  oke_image_id = local.arm_images[0]
}

resource "oci_containerengine_cluster" "transcriber_cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = local.latest_k8s_version
  name               = "transcriber-cluster"
  vcn_id             = oci_core_vcn.transcriber_vcn.id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.transcriber_public_subnet.id
  }
}

resource "oci_containerengine_node_pool" "transcriber_node_pool" {
  cluster_id         = oci_containerengine_cluster.transcriber_cluster.id
  compartment_id     = var.compartment_ocid
  kubernetes_version = local.latest_k8s_version
  name               = "transcriber-pool"
  node_shape         = "VM.Standard.A1.Flex"

  node_shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  node_config_details {
    size = 1
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.transcriber_public_subnet.id
    }
    is_pv_encryption_in_transit_enabled = false
    freeform_tags = {
      "oci_compute_is_preemptible" = "true"
    }
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = local.oke_image_id
  }
}