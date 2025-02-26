output "k8s_master_external_ip" {
  value = yandex_compute_instance.k8s_master.network_interface.0.nat_ip_address
}

output "k8s_master_internal_ip" {
  value = yandex_compute_instance.k8s_master.network_interface.0.ip_address
}

output "k8s_node1_external_ip" {
  value = yandex_compute_instance.k8s_node1.network_interface.0.nat_ip_address
}

output "k8s_node1_internal_ip" {
  value = yandex_compute_instance.k8s_node1.network_interface.0.ip_address
}

output "k8s_node2_external_ip" {
  value = yandex_compute_instance.k8s_node2.network_interface.0.nat_ip_address
}

output "k8s_node2_internal_ip" {
  value = yandex_compute_instance.k8s_node2.network_interface.0.ip_address
}
