output "server_ip" {
  description = "Server public IP address"
  value       = module.instance_server.public_ip
}

output "fe_ip" {
  description = "Frontend public IP address"
  value       = module.instance_frontend.public_ip
}