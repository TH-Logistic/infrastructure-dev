output "server_ip" {
  description = "Server public IP address"
  value       = module.instance_server.public_ip
}