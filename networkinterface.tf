resource "azurerm_network_interface" "Nic" {
  count               = length(var.vm_ids)
  name                = "nic-${count.index + 1}"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  depends_on          = [azurerm_public_ip.PIP]

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.Snet[count.index + 1].id
    private_ip_address_allocation = var.pipall-name
    public_ip_address_id          = azurerm_public_ip.PIP[count.index].id
  }



}
# resource "azurerm_network_interface" "Nic-02" {
#   name                = var.nic-name2
#   location            = azurerm_resource_group.RG.location
#   resource_group_name = azurerm_resource_group.RG.name

#   depends_on = [azurerm_network_interface.Nic]
#   ip_configuration {
#     name                          = "ipconfig"
#     subnet_id                     = azurerm_subnet.Snet[1].id
#     private_ip_address_allocation = var.pipall-name
#     public_ip_address_id          = azurerm_public_ip.PIP[1].id

#   }
# }


resource "azurerm_subnet_network_security_group_association" "nsgassociation" {
  count                     = 3
  subnet_id                 = azurerm_subnet.Snet[count.index].id
  network_security_group_id = azurerm_network_security_group.NSG.id
}
# resource "azurerm_linux_virtual_machine_network_security_group" "name" {
#   count =2
#   virtual_machine_id=azurerm_linux_virtual_machine.VM[count.index].id
#   network_security_group_id = azurerm_network_security_group.NSG.id
# }




