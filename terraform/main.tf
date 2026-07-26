terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "gitops" {
  name     = var.resource_group_name
  location = var.location
}
