data "azurerm_resource_group" "target" {
  name = var.resource_group_name
}

resource "azurerm_service_plan" "website" {
  name                = var.service_plan_name
  resource_group_name = data.azurerm_resource_group.target.name
  location            = data.azurerm_resource_group.target.location
  os_type             = "Linux"
  sku_name            = var.service_plan_sku
}

resource "azurerm_linux_web_app" "website" {
  name                = var.app_service_name
  resource_group_name = data.azurerm_resource_group.target.name
  location            = data.azurerm_resource_group.target.location
  service_plan_id     = azurerm_service_plan.website.id
  https_only          = true

  site_config {
    always_on        = false
    app_command_line = "pm2 serve /home/site/wwwroot --no-daemon --spa"

    application_stack {
      node_version = "22-lts"
    }
  }
}
