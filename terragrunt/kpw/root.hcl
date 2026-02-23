locals {
  subscription = read_terragrunt_config(find_in_parent_folders("subscription.hcl")).locals.subscription_id 
}

inputs = {
  environment         = "poc"
  company             = "ncd" 
  location            = "southeastasia"
  project_name        = "aks"


  common_tags = {
    "Environment" = "poc"
    "Project"     = "aks"
    "Company"     = "ncd"
    "Terraform"   = "true"
  }
}

#  Generate Azure provider
generate "versions" {
  path = "version_override.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  terraform {
    required_providers {
      azurerm = {
        source  = "hashicorp/azurerm"
        # version = ">= 3.51, < 4.0"
        version = ">= 4.16.0, < 5.0.0"
      }
    }
  }
    provider "azurerm" {
        features {}
        subscription_id = "${local.subscription}"
    }
EOF
}

remote_state {
  backend = "azurerm"
  config = {
    subscription_id = local.subscription 
    resource_group_name = get_env("TF_RESOURCE_GROUP") #"rg-tfstate-sea"
    storage_account_name = get_env("TF_STORAGE_ACCOUNT") #"stglabnctfstate"
    container_name       = "tfstate"
    key                  = "${get_path_from_repo_root()}/terraform.tfstate"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}