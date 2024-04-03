resource "azurerm_subnet" "Snet" {
  count                = 3
  name                 = element(var.sub-name, count.index)
  address_prefixes     = [element(var.ip-name, count.index)]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.RG.name
  depends_on           = [azurerm_virtual_network.vnet]

}

