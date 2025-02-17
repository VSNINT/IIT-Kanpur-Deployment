variable "region" {
  default = "Central India"
}

variable "resource_group_name" {
  default = "rg-prod-iit-kanpur"
}

variable "vnet_name" {
  default = "vnet-prod-iit-kanpur"
}

variable "subnet_name" {
  default = "subnet-prod-iit-kanpur"
}

variable "mysql_server_name" {
  default = "mysql-prod-iit-kanpur"
}

variable "vm_count" {
  default = 14
}

variable "vm_size" {
  default = "Standard_B2as_v2"
}

variable "admin_username" {
  default = "azureuser"
}

# Azure Authentication Variables
variable "client_id" {
  description = "The client ID of the Azure service principal"
  type        = string
}

variable "client_secret" {
  description = "The client secret of the Azure service principal"
  type        = string
}

variable "tenant_id" {
  description = "The tenant ID of the Azure subscription"
  type        = string
}

variable "subscription_id" {
  description = "The subscription ID of the Azure subscription"
  type        = string
}
