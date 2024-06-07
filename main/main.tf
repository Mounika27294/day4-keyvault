data "azurerm_client_config" "current" {}

module "resource_group" {    
  source    = "../modules/resourcegroup"
  rg_name   = var.rg_name
  location  = var.location  
  tags      = var.tags
}

module "key_vault" {    
  source    = "../modules/keyvault"
  depends_on = [ module.resource_group ]
  kv_name   = var.kv_name
  rg_name   = var.rg_name
  location  = var.location  
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
}

module "cosmodb_account" {    
  source    = "../modules/cosmodb"
  depends_on = [ module.key_vault ]
  rg_name   = var.rg_name
  location  = var.location  
}

module "key_vault_secret" {
  source              = "../modules/keyvaultsecret"
  depends_on          = [module.key_vault, module.cosmodb_account]
  key_vault_id        = module.key_vault.key_vault_id
  secret_names = {
    "cosmo-db-primary-key"   = module.cosmodb_account.primary_key
    "cosmo-db-secondary-key" = module.cosmodb_account.secondary_key
  }
}






