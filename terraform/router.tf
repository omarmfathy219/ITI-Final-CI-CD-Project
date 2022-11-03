resource "google_compute_router" "router" {
  name    = "router"
  region  = google_compute_subnetwork.management_subnet.region
  network = google_compute_network.omar-vpc.id
}