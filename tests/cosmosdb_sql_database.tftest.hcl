mock_provider "azurerm" {}

variables {
  resource_groups = {
    Project = {
      name = "rg-project"
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project"
    }
  }
  env               = "Dev1"
  group             = "SPC"
  project           = "TST"
  userDefinedString = "test"
  tags              = {}
}

run "naming_convention" {
  command = plan

  variables {
    cosmosdb_sql_database_config = {
      serverType     = "CPS"
      resource_group = "Project"
      account_name   = "my-cosmosdb-account"
    }
  }

  assert {
    condition     = azurerm_cosmosdb_sql_database.cosmosdb-sql-database.name == "Dev1CPS-test-sdb"
    error_message = "Name must follow {env4}{serverType3}-{userDefinedString7}-sdb convention"
  }
}

run "default_values" {
  command = plan

  variables {
    cosmosdb_sql_database_config = {
      serverType     = "CPS"
      resource_group = "Project"
      account_name   = "my-cosmosdb-account"
    }
  }

  assert {
    condition     = length(azurerm_cosmosdb_sql_database.cosmosdb-sql-database.autoscale_settings) == 0
    error_message = "Default autoscale_settings must be empty when not provided"
  }
}

run "manual_throughput" {
  command = plan

  variables {
    cosmosdb_sql_database_config = {
      serverType     = "CPS"
      resource_group = "Project"
      account_name   = "my-cosmosdb-account"
      throughput     = 400
    }
  }

  assert {
    condition     = azurerm_cosmosdb_sql_database.cosmosdb-sql-database.throughput == 400
    error_message = "Manual throughput must be set to the provided value"
  }
}

run "autoscale_settings" {
  command = plan

  variables {
    cosmosdb_sql_database_config = {
      serverType     = "CPS"
      resource_group = "Project"
      account_name   = "my-cosmosdb-account"
      autoscale_settings = {
        max_throughput = 4000
      }
    }
  }

  assert {
    condition     = length(azurerm_cosmosdb_sql_database.cosmosdb-sql-database.autoscale_settings) == 1
    error_message = "autoscale_settings block must be present when configured"
  }
}

run "name_override" {
  command = plan

  variables {
    cosmosdb_sql_database_config = {
      serverType     = "CPS"
      resource_group = "Project"
      account_name   = "my-cosmosdb-account"
      name           = "my-custom-db-name"
    }
  }

  assert {
    condition     = azurerm_cosmosdb_sql_database.cosmosdb-sql-database.name == "my-custom-db-name"
    error_message = "Explicit name override must take precedence over the generated name"
  }
}

run "resource_group_id" {
  command = plan

  variables {
    cosmosdb_sql_database_config = {
      serverType     = "CPS"
      resource_group = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project"
      account_name   = "my-cosmosdb-account"
    }
  }

  assert {
    condition     = azurerm_cosmosdb_sql_database.cosmosdb-sql-database.resource_group_name == "rg-project"
    error_message = "Resource group name must be parsed from the ARM resource ID when a full ID is provided"
  }
}
