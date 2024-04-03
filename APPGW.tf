resource "azurerm_public_ip" "PIP-01" {
  name                = "PIP-01"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = "Static"
  sku_tier            = "Regional"
  sku                 = "Standard"

}
# Azure Application Gateway - Locals Block 
#since these variables are re-used - a locals block makes this more maintainable
locals {
  # Generic 
  frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
  listener_name                  = "${azurerm_virtual_network.vnet.name}-httplstn"
  request_routing_rule1_name     = "${azurerm_virtual_network.vnet.name}-rqrt-1"
  url_path_map                   = "${azurerm_virtual_network.vnet.name}-upm-app1-app2"

  # App1
  backend_address_pool_name_app1 = "${azurerm_virtual_network.vnet.name}-beap-app1"
  http_setting_name_app1         = "${azurerm_virtual_network.vnet.name}-be-htst-app1"
  probe_name_app1                = "${azurerm_virtual_network.vnet.name}-be-probe-app1"

  # App2
  backend_address_pool_name_app2 = "${azurerm_virtual_network.vnet.name}-beap-app2"
  http_setting_name_app2         = "${azurerm_virtual_network.vnet.name}-be-htst-app2"
  probe_name_app2                = "${azurerm_virtual_network.vnet.name}-be-probe-app2"

  # # Default Redirect on Root Context (/)
  # redirect_configuration_name = "${azurerm_virtual_network.vnet.name}-rdrcfg"

}
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "example" {
  network_interface_id    = azurerm_network_interface.Nic[0].id
  ip_configuration_name   = "ipconfig"
  backend_address_pool_id = tolist(azurerm_application_gateway.web_ag.backend_address_pool).0.id
}
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "example-01" {
  network_interface_id    = azurerm_network_interface.Nic[1].id
  ip_configuration_name   = "ipconfig"
  backend_address_pool_id = tolist(azurerm_application_gateway.web_ag.backend_address_pool).1.id
}

# Resource-2: Azure Application Gateway - Standard
resource "azurerm_application_gateway" "web_ag" {
  name                = "web-ag"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
    #capacity = 2
  }
  autoscale_configuration {
    min_capacity = 0
    max_capacity = 10
  }
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.Snet[0].id
  }
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.PIP-01.id
  }
  # Listerner: HTTP Port 80
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }
  # App1 Backend Configs
  backend_address_pool {
    name = local.backend_address_pool_name_app1
  }
  backend_http_settings {
    name                  = local.http_setting_name_app1
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    path                  = "/"# Adjusted path
     pick_host_name_from_backend_address = true
    probe_name            = local.probe_name_app1
    #pick_host_name_from_backend_http_settings = true  # Added property
  }
  probe {
    name                                      = local.probe_name_app1
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    protocol                                  = "Http"
    port                                      = 80
    path                                      = "/"
    pick_host_name_from_backend_http_settings = true
    # match {
    #   body        = "App1"
    #   status_code = ["200"]
    # }
  }
  backend_address_pool {
    name = local.backend_address_pool_name_app2
  }
  backend_http_settings {
    name                  = local.http_setting_name_app2
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    path                  = "/songs/" 
     pick_host_name_from_backend_address = true
    probe_name = local.probe_name_app2
    
  }
  probe {
    name                                      = local.probe_name_app2
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    protocol                                  = "Http"
    port                                      = 80
    path                                      = "/songs/"
     pick_host_name_from_backend_http_settings = true
    # match {
    #   body        = "App2"
    #   status_code = ["200"]
    # }
  }
  # Path based Routing Rule
  request_routing_rule {
    name               = local.request_routing_rule1_name
    rule_type          = "PathBasedRouting"
    http_listener_name = local.listener_name
    url_path_map_name  = local.url_path_map
    priority           = 9
    backend_address_pool_name  = local.backend_address_pool_name_app1
    backend_http_settings_name = local.http_setting_name_app1
  }
  # URL Path Map - Define Path based Routing    
  url_path_map {
    name                                = local.url_path_map
    #default_redirect_configuration_name = local.redirect_configuration_name
    default_backend_address_pool_name = local.backend_address_pool_name_app1 
    default_backend_http_settings_name = local.http_setting_name_app1
    # path_rule {
    #   name                       = "app1-rule"
    #   paths                      = ["/music/*"]
    #   backend_address_pool_name  = local.backend_address_pool_name_app1
    #   backend_http_settings_name = local.http_setting_name_app1
    # }
    path_rule { 
      name                       = "app2-rule"
      paths                      = ["/songs/"]
      backend_address_pool_name  = local.backend_address_pool_name_app2
      backend_http_settings_name = local.http_setting_name_app2
    }
  }
  # Default Root Context (/ - Redirection Config)
  # redirect_configuration {
  #   name          = local.redirect_configuration_name
  #   redirect_type = "Temporary"
  #   target_url    = "http://40.114.51.251/music/ "
    
  # }

}