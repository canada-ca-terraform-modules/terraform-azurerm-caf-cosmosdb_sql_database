# config/cosmosdb_sql_database.tfvars
# Tracked, ready-to-run fixture for the test/live harness - one representative
# real-usage instance (manual throughput, no autoscale), not a two-code-path
# engineered fixture and not a dormant "_" template.
#
# account_name here is a base name only - test/live/main.tf appends
# var.pr_number to it before passing it to the module, since CosmosDB
# account names must be globally unique.
#
# Maintained by whoever adds a new optional input to the module: update this
# file in the same PR if you want live coverage of it, same discipline as
# updating tests/cosmosdb_sql_database.tftest.hcl.

env = "test"

cosmosdb_sql_database_config = {
  serverType     = "CPS"
  resource_group = "Project"
  account_name   = "cdblivetest"
  throughput     = 400
}
