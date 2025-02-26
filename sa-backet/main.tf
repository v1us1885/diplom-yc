provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
}

# Создание сервисного аккаунта
resource "yandex_iam_service_account" "terraform" {
  name        = "terraform-sa"
  description = "Service account for Terraform"
}

# Назначение роли storage.admin сервисному аккаунту (для управления бакетом)
resource "yandex_resourcemanager_folder_iam_binding" "storage_admin" {
  folder_id = var.yc_folder_id
  role      = "storage.admin"
  members   = [
    "serviceAccount:${yandex_iam_service_account.terraform.id}"
  ]
}

# Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.terraform.id
  description        = "Static access key for Terraform"
}

# Создание S3-бакета для хранения Terraform state
resource "yandex_storage_bucket" "tfstate" {
  bucket     = "bucket-tfstate"
  folder_id  = var.yc_folder_id  # <-- Добавляем folder_id!
  force_destroy = true
}

# Создание backend.tf для Terraform
resource "local_file" "backend" {
  content  = <<EOT
terraform {
  backend "s3" {
    endpoint   = "https://storage.yandexcloud.net"
    bucket     = "${yandex_storage_bucket.tfstate.bucket}"
    region     = "ru-central1"
    key        = "terraform.tfstate"
    access_key = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
    secret_key = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true 
    skip_s3_checksum            = true 
  }
}
EOT
  filename = "../infrastructure/backend.tf"
}
