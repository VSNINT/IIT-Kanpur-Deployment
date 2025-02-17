

output "vm_credentials_file" {
  value = local_file.vm_credentials.filename
}

output "mysql_credentials_file" {
  value = local_file.mysql_credentials.filename
}

output "mysql_server_fqdn" {
  value = azurerm_mysql_flexible_server.mysql.fqdn
}
