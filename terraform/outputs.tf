output "website_url" {
  description = "HTTPS URL of the deployed Azure App Service."
  value       = "https://${azurerm_linux_web_app.website.default_hostname}"
}

output "resource_group_name" {
  description = "Resource group containing the website resources."
  value       = data.azurerm_resource_group.target.name
}

output "app_service_name" {
  description = "Deployed App Service name."
  value       = azurerm_linux_web_app.website.name
}
