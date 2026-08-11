# Purpose: catch breaking resource changes introduced by the azurerm ~> 4.0 -> ~> 5.0
# provider bump before real infra is touched.
# How: run blocks share state — apply creates mock state; next plan runs against it.
# If the upgraded provider constraint caused an address change or accidental destroy,
# it would appear in the second run's plan.
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

# Step 1: simulate the currently-deployed resource (pre-upgrade inputs, no new args)
run "baseline_apply" {
  command = apply

  variables {
    cosmosdb_sql_database_config = {
      serverType     = "CPS"
      resource_group = "Project"
      account_name   = "my-cosmosdb-account"
    }
  }

  assert {
    condition     = azurerm_cosmosdb_sql_database.cosmosdb-sql-database.name == "Dev1CPS-test-sdb"
    error_message = "Baseline apply: unexpected resource name"
  }
}

# Step 2: plan the upgraded provider-constrained code against that state, adding an
# optional argument (throughput) to prove additive changes remain in-place, not destroy+create
run "upgrade_plan_no_replacement" {
  command = plan # plans against state from baseline_apply

  variables {
    cosmosdb_sql_database_config = {
      serverType     = "CPS"
      resource_group = "Project"
      account_name   = "my-cosmosdb-account"
      throughput     = 400
    }
  }

  assert {
    condition     = azurerm_cosmosdb_sql_database.cosmosdb-sql-database.name == "Dev1CPS-test-sdb"
    error_message = "Resource name must be unchanged after upgrade"
  }

  assert {
    condition     = azurerm_cosmosdb_sql_database.cosmosdb-sql-database.throughput == 400
    error_message = "throughput must be set to the provided value"
  }
}
