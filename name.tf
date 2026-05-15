locals {
  cosmosdb_sql_database_regex = "/[\"'\\[\\]:|<>+=;,?*@&]/"
  env_4                       = substr(var.env, 0, 4)
  serverType_3                = substr(var.cosmosdb_sql_database_config.serverType, 0, 3)
  userDefinedString_7         = substr(var.userDefinedString, 0, 7)
  cosmosdb-sql-database-name  = replace("${local.env_4}${local.serverType_3}-${local.userDefinedString_7}-sdb", local.cosmosdb_sql_database_regex, "")
}
