resource "azurerm_public_ip" "PIP" {
  count               = 2
  name                = var.pip-name[count.index]
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = var.all-name
  depends_on          = [azurerm_subnet.Snet]

}