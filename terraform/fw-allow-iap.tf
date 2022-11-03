#IAP firwall 
resource "google_compute_firewall" "allow-iap" {
  name    = "allow-iap"
  network = google_compute_network.omar-vpc.id
  allow {
    protocol = "tcp"
    ports    = ["22" , "80"]
  }
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
}