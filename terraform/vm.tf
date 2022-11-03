#create private VM
resource "google_compute_instance" "private-vm2" {
  name         = "private-vm2"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  #Debian Image to run kubectl
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  #attach private-vm with management subnet
  network_interface {
    network = google_compute_network.omar-vpc.id
    subnetwork = google_compute_subnetwork.management_subnet.id
  }

}
