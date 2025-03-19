terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.13"
    }
  }
}

provider "yandex" {
  service_account_key_file = "../sa-key-init.json"
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
}