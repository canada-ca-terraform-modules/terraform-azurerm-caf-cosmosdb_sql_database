terraform {
  required_version = ">= 1.9"
}

variable "cosmosdb_sql_databases" {
  description = "Map of CosmosDB SQL Database configuration objects. Each key becomes the userDefinedString."
  type        = any
  default     = {}
}

# tflint-ignore: terraform_unused_declarations
variable "resource_groups" {
  description = "Map of resource group objects"
  type        = any
  default     = {}
}

module "cosmosdb_sql_databases" {
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-cosmosdb_sql_databaseV2.git?ref=v1.1.0"
  for_each = var.cosmosdb_sql_databases

  env                          = var.env
  group                        = var.group
  project                      = var.project
  userDefinedString            = each.key
  location                     = var.location
  tags                         = var.tags
  resource_groups              = local.resource_groups_all
  cosmosdb_sql_database_config = each.value
}
