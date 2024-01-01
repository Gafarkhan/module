variable "azurerm_resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "azurerm_virtual_network" {
  type = string
}

variable "address_space" {
  type = list 
}

variable "subnet1" {
  type = string
}

variable "address_prefixes1" {
  type = list 
}

variable "subnet2" {
  type = string
}

variable "address_prefixes2" {
  type = list 
}

variable "azurerm_network_security_group" {
  type = string
}

variable "azurerm_network_interface" {
  type = string
}

variable "azurerm_virtual_machine" {
  type = string
}

variable "public_ip" {
  type = string
}

variable "azurerm_LB" {
  type = string
}

variable "frontend_ip_configuration" {
  type = string
}