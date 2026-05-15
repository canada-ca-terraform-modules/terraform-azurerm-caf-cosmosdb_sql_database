output "cosmosdb_sql_database_object" {
  description = "Outputs the entire CosmosDB SQL Database object"
  sensitive   = true
  value       = azurerm_cosmosdb_sql_database.cosmosdb-sql-database
}

output "cosmosdb_sql_database_id" {
  description = "Outputs the id of the CosmosDB SQL Database"
  value       = azurerm_cosmosdb_sql_database.cosmosdb-sql-database.id
}

output "cosmosdb_sql_database_name" {
  description = "Outputs the name of the CosmosDB SQL Database"
  value       = azurerm_cosmosdb_sql_database.cosmosdb-sql-database.name
}
