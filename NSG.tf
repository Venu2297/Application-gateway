resource "azurerm_network_security_group" "NSG" {
  name                = var.nsg-name
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  #depends_on          = [azurerm_network_interface.Nic]
  security_rule {
    name                       = var.sec-name
    priority                   = var.value
    direction                  = var.dic-name
    access                     = var.acc-name
    protocol                   = var.pt-name
    source_port_range          = var.sport-name
    destination_port_range     = var.dport-name
    source_address_prefix      = var.sadd-name
    destination_address_prefix = var.dadd-name
  }


}

