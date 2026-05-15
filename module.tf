resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = var.cosmosdb_sql_database_config.account_name
  location            = var.location
  resource_group_name = local.resource_group_name
  offer_type          = "Standard"
  kind                = try(var.cosmosdb_sql_database_config.account_kind, "GlobalDocumentDB")
  tags                = var.tags

  public_network_access_enabled     = try(var.cosmosdb_sql_database_config.public_network_access_enabled, false)
  is_virtual_network_filter_enabled = try(var.cosmosdb_sql_database_config.is_virtual_network_filter_enabled, false)

  consistency_policy {
    consistency_level       = try(var.cosmosdb_sql_database_config.consistency_level, "Session")
    max_interval_in_seconds = try(var.cosmosdb_sql_database_config.max_interval_in_seconds, 5)
    max_staleness_prefix    = try(var.cosmosdb_sql_database_config.max_staleness_prefix, 100)
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "cosmosdb-sql-database" {
  # Name: explicit override > SSC CAF generated default
  name                = try(var.cosmosdb_sql_database_config.name, local.cosmosdb-sql-database-name)
  resource_group_name = local.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name

  # Optional: manual throughput (RU/s). Min 400, increments of 100, max 1,000,000.
  # Must be set on database creation — cannot be updated without destroy-apply.
  # Do not set when the CosmosDB account has the EnableServerless capability.
  # Conflicts with autoscale_settings.
  throughput = try(var.cosmosdb_sql_database_config.throughput, null)

  # Optional: autoscale throughput settings. Conflicts with throughput.
  # Must be set on database creation — cannot switch modes without destroy-apply.
  dynamic "autoscale_settings" {
    for_each = try(var.cosmosdb_sql_database_config.autoscale_settings, null) != null ? [1] : []
    content {
      # max_throughput: 1,000–1,000,000 RU/s in increments of 1,000
      max_throughput = try(var.cosmosdb_sql_database_config.autoscale_settings.max_throughput, null)
    }
  }
}
