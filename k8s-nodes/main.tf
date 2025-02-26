provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
}

resource "yandex_compute_instance" "k8s_master" {
  name        = "k8s-master"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"

  resources {
    cores  = 2
    memory = 4
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true  # Установка инстанса как прерываемый
  }

  boot_disk {
    initialize_params {
      image_id = "fd89sohb28dqsoq35u7j"
      size     = 20
    }
  }

  network_interface {
    subnet_id = data.terraform_remote_state.network.outputs.subnet_a_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "k8s_node1" {
  name        = "k8s-node1"
  zone        = "ru-central1-b"
  platform_id = "standard-v2"

  resources {
    cores  = 2
    memory = 4
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true  # Установка инстанса как прерываемый
  }

  boot_disk {
    initialize_params {
      image_id = "fd89sohb28dqsoq35u7j"
      size     = 20
    }
  }

  network_interface {
    subnet_id = data.terraform_remote_state.network.outputs.subnet_b_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "k8s_node2" {
  name        = "k8s-node2"
  zone        = "ru-central1-d"
  platform_id = "standard-v2"

  resources {
    cores  = 2
    memory = 4
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true  # Установка инстанса как прерываемый
  }

  boot_disk {
    initialize_params {
      image_id = "fd89sohb28dqsoq35u7j"
      size     = 20
    }
  }

  network_interface {
    subnet_id = data.terraform_remote_state.network.outputs.subnet_d_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
