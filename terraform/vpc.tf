#create new vpc
resource "google_compute_network" "omar-vpc" {
  name                    = "omar-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}