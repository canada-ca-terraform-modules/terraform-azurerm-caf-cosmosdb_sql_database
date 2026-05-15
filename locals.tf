locals {
  # If resource_group was an ID, then parse the ID for the name, if not, then search in the provided resource_groups object
  resource_group_name = strcontains(var.cosmosdb_sql_database_config.resource_group, "/resourceGroups/") ? regex("[^/]+$", var.cosmosdb_sql_database_config.resource_group) : var.resource_groups[var.cosmosdb_sql_database_config.resource_group].name
}
