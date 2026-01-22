terraform {
  required_providers {
    yandex = {
      source = "terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

variable "vms" {
  description = "Конфигурация виртуальных машин"
  type = map(object({
    cores  = number
    memory = number
    disk   = number
  }))
  default = {
    builder = { cores = 2, memory = 2, disk = 20 },
    public  = { cores = 2, memory = 2, disk = 20 },
  }
}

variable "img" {
  type = string
  default = "fd8iqikoo07s23bhh1vj"
}

resource "yandex_compute_instance" "vm" {

  for_each = var.vms

    name = "${each.key}"
    boot_disk {
      initialize_params {
        image_id = var.img 
        size     = each.value.disk
      }
    }
  
    resources {
      cores  = each.value.cores
      memory = each.value.memory
    }

    metadata = {
      ssh-keys = "ubuntu:${file("id_ed25519.pub")}"
    }

    network_interface {
      subnet_id = "e9b7m8esv1qpccpq4793"
      nat       = true
    }
}
