terraform {
  backend "remote"{
    hostname = "app.terraform.io"
    organization = "devops-coursera"

    workspaces {
      name = "devops-coursera"
    }
  }

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
}

variable "ssh_pub_key" {
  type = string
}

variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}
resource "yandex_compute_instance" "prod-vm" {

  name        = "terraform-prod-vm"
#  platform_id = "standard-v1"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd81a49qficqvt0dthu8"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.prod-subnet.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "podkovka:${var.ssh_pub_key}"
  }
}

resource "yandex_vpc_network" "prod-network" {
  name = "terraform-prod-network"
}

resource "yandex_vpc_subnet" "prod-subnet" {
  name       = "terraform-prod-subnet"
  zone       = "ru-central1-a"
  network_id = "${yandex_vpc_network.prod-network.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_prod_vm" {
  value = "${yandex_compute_instance.prod-vm.network_interface.0.ip_address}"
}

output "external_ip_address_prod_vm" {
  value = "${yandex_compute_instance.prod-vm.network_interface.0.nat_ip_address}"
}
