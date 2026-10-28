variable "subscription_id" {
  description = "Azure subscription ID. Supply through TF_VAR_subscription_id or terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Existing resource group in which the App Service will be created."
  type        = string
  default     = "devops-rg"
}

variable "location" {
  description = "Azure region for the hosting plan and web app."
  type        = string
  default     = "centralindia"
}

variable "app_service_name" {
  description = "Globally unique Azure App Service name."
  type        = string
  default     = "azure-devops-abunesh-2026"
}

variable "service_plan_name" {
  description = "Name of the Linux App Service plan."
  type        = string
  default     = "azure-devops-plan-2026"
}

variable "service_plan_sku" {
  description = "App Service plan SKU. B1 is a small paid Linux tier."
  type        = string
  default     = "B1"
}
