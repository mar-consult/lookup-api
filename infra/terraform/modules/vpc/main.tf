resource "google_compute_network" "vpc_network" {
  
  name                    = "my-vpc-network"
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "private_subnets" {
  for_each                 = { for sub in var.private_subnets : sub.cidr_block => sub }
  
  name                     = "private-${each.value.region}"
  ip_cidr_range            = each.key
  network                  = google_compute_network.vpc_network.id
  region                   = each.value.region
  private_ip_google_access = true
}


resource "google_compute_subnetwork" "public_subnet_one" {
  for_each      = { for sub in var.public_subnets : sub.cidr_block => sub }
  
  name          = "public-${each.value.region}"
  ip_cidr_range = each.key
  network       = google_compute_network.vpc_network.id
  region        = each.value.region
}



resource "google_compute_router" "nat_router" {
  for_each = { for sub in var.private_subnets : sub.cidr_block => sub }
  
  name     = "nat-router-${each.value.region}"
  network  = google_compute_network.vpc_network.id
  region   = each.value.region
  bgp {
    asn = 64515
  }
}

resource "google_compute_router_nat" "nat" {
  for_each                           = { for sub in var.private_subnets : sub.cidr_block => sub }
  name                               = "router-nat-${each.value.region}"
  router                             = google_compute_router.nat_router[each.key].name
  region                             = each.value.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnets[each.key].id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]

  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


resource "google_compute_route" "my_route" {
  
  name             = "my-route-to-internet"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc_network.id
  next_hop_gateway = "default-internet-gateway"


  priority = 1000
}
