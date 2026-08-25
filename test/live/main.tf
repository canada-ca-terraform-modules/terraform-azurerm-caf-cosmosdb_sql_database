terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }

  # Empty on purpose: the state file path is supplied at `terraform init`
  # time via `-backend-config="path=..."` (partial configuration), so the
  # target-branch checkout and the PR-branch checkout can point at the same
  # external state file without either owning its own local state.
  backend "local" {}
}

provider "azurerm" {
  storage_use_azuread             = true
  resource_provider_registrations = "legacy"
  features {}
}

module "cosmosdb_sql_database" {
  # PR code and baseline code are two on-disk checkouts of this same repo,
  # not two resolved git refs - no pinned ?ref, no version toggle here.
  source = "../../"

  env               = var.env
  group             = "livetest"
  project           = "livetest"
  location          = var.location
  tags              = var.tags
  userDefinedString = "livetest"
  resource_groups   = local.resource_groups # from test_dependencies.tf

  # account_name must be globally unique across Azure - the tfvars fixture's
  # base name is suffixed with pr_number so concurrently open PRs never
  # collide on the same sandbox subscription.
  cosmosdb_sql_database_config = merge(
    var.cosmosdb_sql_database_config,
    { account_name = "${var.cosmosdb_sql_database_config.account_name}${var.pr_number}" }
  )
}
