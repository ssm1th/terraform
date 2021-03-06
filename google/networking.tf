# Create the network to host Slurm
resource "google_compute_network" "vpc_network" {
  name                    = "citc-net-${local.cluster_id}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name          = "citc-subnet-${local.cluster_id}"
  ip_cidr_range = var.network_ipv4_cidr
  network       = google_compute_network.vpc_network.self_link
}

# Add some firewall rules
resource "google_compute_firewall" "open-internal" {
  name        = "open-internal-${local.cluster_id}"
  network     = google_compute_network.vpc_network.name
  source_tags = ["mgmt-${local.cluster_id}", "compute-${local.cluster_id}", "nfs-${local.cluster_id}"]
  target_tags = ["mgmt-${local.cluster_id}", "compute-${local.cluster_id}", "nfs-${local.cluster_id}"]
  allow {
    protocol = "tcp"
  }
}

# Open high ports for applications
resource "google_compute_firewall" "high-range" {
  name          = "high-range-to-mgmt-${local.cluster_id}"
  network       = google_compute_network.vpc_network.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mgmt-${local.cluster_id}"]
  allow {
    protocol = "tcp"
    ports    = ["1024-65535"]
  }
}

resource "google_compute_firewall" "ssh" {
  name          = "ssh-to-mgmt-${local.cluster_id}"
  network       = google_compute_network.vpc_network.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mgmt-${local.cluster_id}"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "http" {
  name          = "http-to-mgmt-${local.cluster_id}"
  network       = google_compute_network.vpc_network.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mgmt-${local.cluster_id}"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
