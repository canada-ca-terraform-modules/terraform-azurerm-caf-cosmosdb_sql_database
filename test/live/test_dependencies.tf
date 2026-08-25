# test_dependencies.tf
# Self-contained dependency resource, owned entirely by this harness.
#
# Deliberately NOT reusing any shared/production resource group: writing
# into a shared RG usually requires elevated, non-sandbox permissions. A
# dedicated throwaway RG here needs only Contributor on the sandbox
# subscription and can never collide with or affect any production
# resource.

resource "azurerm_resource_group" "live_test" {
  # PR-number suffix keeps two concurrently open PRs against this module
  # from colliding on the same sandbox resource group.
  name     = "${var.env}-caf-cosmosdb-sql-database-live-test-${var.pr_number}-rg"
  location = var.location

  tags = {
    "pr-number" = var.pr_number
  }
}

locals {
  # terraform-azurerm-caf-cosmosdb_sql_database expects a resource_groups map
  # keyed by purpose, each entry exposing at least `.name`.
  resource_groups = {
    Project = { name = azurerm_resource_group.live_test.name }
  }
}
