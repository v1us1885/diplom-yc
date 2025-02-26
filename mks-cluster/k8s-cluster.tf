resource "yandex_kubernetes_cluster" "k8s_cluster" {
  name        = "mks-cluster"
  description = "Managed Kubernetes cluster in Yandex.Cloud"
  network_id  = data.terraform_remote_state.network.outputs.network_id

  service_account_id      = data.terraform_remote_state.sa_backet.outputs.service_account_id
  node_service_account_id = data.terraform_remote_state.sa_backet.outputs.service_account_id

  master {
    regional {
      region = "ru-central1"

      location {
        zone      = "ru-central1-a"
        subnet_id = data.terraform_remote_state.network.outputs.subnet_a_id
      }

      location {
        zone      = "ru-central1-b"
        subnet_id = data.terraform_remote_state.network.outputs.subnet_b_id
      }

      location {
        zone      = "ru-central1-d"
        subnet_id = data.terraform_remote_state.network.outputs.subnet_d_id
      }
    }

    public_ip = true
  }

  release_channel = "RAPID"
}
