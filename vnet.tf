resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet-name
  address_space       = var.add-name
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  depends_on          = [azurerm_resource_group.RG]

}

