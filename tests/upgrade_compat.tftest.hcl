# Purpose: prove a pre-upgrade-shaped cosmosdb_sql_database_config still applies
# cleanly, and stays in-place (no destroy/recreate), when a caller adds one new
# optional argument on top of it.
#
# Scope / limitation: `terraform test` resolves a single provider version for the
# whole file from this repo's own providers.tf (now pinned to azurerm ~> 5.0) - it
# cannot mix two provider major versions in one test file, so this does NOT by
# itself validate real 4.x-state -> 5.x-provider migration. That live-state check
# is done separately via a two-phase terraform-module-upgrade-probe run (baseline
# apply under azurerm 4.81.0, then a second plan against that same state under
# this upgraded code / azurerm 5.0.1) against a real Azure subscription.
#
# How: run blocks share state - apply creates mock state; the next run plans
# against it. baseline_apply's own resource id is captured and compared against
# the second run's planned id - a resource being replaced re-computes id as
# unknown, which fails the equality assertion (or errors as an unknown-value
# condition), so recreation cannot silently pass as a no-op.
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

# Step 2: plan the same (current, ~> 5.0-pinned) code against that state, adding an
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

  # No-replacement guard: a replaced resource re-computes id as unknown at plan
  # time, so this equality either fails outright or errors as an unknown-value
  # condition - either way the test fails instead of silently passing.
  assert {
    condition     = azurerm_cosmosdb_sql_database.cosmosdb-sql-database.id == run.baseline_apply.cosmosdb_sql_database_id
    error_message = "Resource must be updated in-place, not destroyed/recreated (id changed)"
  }

  assert {
    condition     = azurerm_cosmosdb_account.cosmosdb_account.id == run.baseline_apply.cosmosdb_account_id
    error_message = "CosmosDB account must be updated in-place, not destroyed/recreated (id changed)"
  }
}
