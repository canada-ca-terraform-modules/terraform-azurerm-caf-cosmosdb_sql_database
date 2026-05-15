cosmosdb_sql_databases = {
  example = {
    serverType     = "CPS"     # 3-char SACM device type: CPS = Cloud Platform Service
    resource_group = "Project" # key in resource_groups map, or full Azure resource ID

    # Required: name of the CosmosDB account that will host this database
    account_name = "my-cosmosdb-account"

    # Optional: Override the auto-generated database name
    # name = "my-custom-db-name"

    # Optional: Manual throughput in RU/s
    #   - Min 400, increments of 100, max 1,000,000
    #   - Must be set on database creation (cannot change mode without destroy-apply)
    #   - Do not set when the CosmosDB account has the EnableServerless capability
    #   - Conflicts with autoscale_settings
    # throughput = 400

    # Optional: Autoscale throughput settings
    #   - Conflicts with throughput
    #   - Must be set on database creation (cannot change mode without destroy-apply)
    # autoscale_settings = {
    #   max_throughput = 4000    # Max RU/s: 1,000–1,000,000 in increments of 1,000
    # }
  }
}
