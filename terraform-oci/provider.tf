terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 8.6.0" # Always use a recent provider version
    }
  }
}

provider "oci" {
  tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaxkh525vdshlefhy3barfyu2hyqe2txslfwx5ixus77zsbraqmkza" # Paste your Tenancy OCID here
  user_ocid        = "ocid1.user.oc1..aaaaaaaavmuoswrqenxvd4dtr5yg35gib3f6bddnhdyteiqdm6o7mjpyggwa"    # Paste your User OCID here
  fingerprint      = "0e:61:23:f8:9b:66:8d:05:75:df:bd:fd:b6:9f:66:d2"    # Paste the fingerprint from the API key popup
  private_key_path = "~/.oci/arka.kk5@gmail.com-2026-03-28T11_05_26.335Z.pem" # Path to the .pem file you downloaded
  region           = "ap-hyderabad-1"         # e.g., us-ashburn-1, ap-mumbai-1
}