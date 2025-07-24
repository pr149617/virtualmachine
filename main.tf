provider "google" {
  project = "canvas-primacy-466005-f9"
  region  = "us-central1"
  zone    = "us-central1-a"
}

# 🔍 Use existing VPC
data "google_compute_network" "dev-vpc" {
  name = "dev-vpc"
  
}

resource "google_compute_subnetwork" "demosubnet" {
  name          = "sandboxsubnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = data.google_compute_network.dev-vpc.self_link

}

# 🖥️ Create a VM with OS Login enabled
resource "google_compute_instance" "vm_oslogin" {
  name         = "sandbox-oslogin"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = data.google_compute_network.dev-vpc.self_link
    subnetwork = google_compute_subnetwork.demosubnet.self_link


    access_config {} # Assign external IP for SSH
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  tags = ["oslogin"]
}

# 🔐 IAM binding for OS Login with sudo
resource "google_compute_instance_iam_member" "oslogin_user" {
  project      = "canvas-primacy-466005-f9"
  zone        = "us-central1-a"
  instance_name = google_compute_instance.vm_oslogin.name
  role    = "roles/compute.osAdminLogin"
  member  = "user:neeluchetri65@gmail.com"  # Replace with actual user
}
