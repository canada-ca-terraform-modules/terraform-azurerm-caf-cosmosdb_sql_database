# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.1.0] - 2026-08-10

### Changed

- Bumped `azurerm` provider constraint from `~> 4.0` to `~> 5.0` (target version `5.0.1`).
- Bumped `ESLZ/CosmosDbSqlDatabase.tf` module `ref=` from `v1.0.0` to `v1.1.0`.

### Added

- `.github/workflows/documentation.yml` — auto-generates README via terraform-docs on PR.
- `.github/workflows/terraform-ci.yml` — fmt/init/validate/test/tflint CI pipeline.
- `.github/workflows/release.yml` — creates a GitHub release on merge to `main`, tagged
  from `ESLZ/CosmosDbSqlDatabase.tf`'s own `?ref=vX.Y.Z`.
- `tests/upgrade_compat.tftest.hcl` — state-chaining test proving the pre-upgrade
  `cosmosdb_sql_database_config` shape still applies cleanly under the upgraded provider
  constraint with no resource replacement.

### Notes

- No breaking changes in azurerm 5.0 affect `azurerm_cosmosdb_sql_database` — this resource
  is not listed in the [5.0 upgrade guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/5.0-upgrade-guide)'s breaking-changes sections.
- `azurerm_cosmosdb_account` breaking changes in 5.0 (`local_authentication_disabled` →
  `local_authentication_enabled`, `managed_hsm_key_id` → `key_vault_key_id`,
  `minimal_tls_version` no longer accepting `Tls`/`Tls11`, `ip_range_filter` type change
  string → list) do not affect this module — none of those arguments are exposed or set
  by `module.tf`'s `azurerm_cosmosdb_account` block.
- Existing `ESLZ/*.tfvars` and `cosmosdb_sql_database_config` inputs require no changes to
  produce an identical plan after this upgrade.

### Known blockers

- None.

## [1.0.0] - Initial release

- Initial module release: `azurerm_cosmosdb_account` + `azurerm_cosmosdb_sql_database`,
  SSC CAF naming convention, manual throughput / autoscale settings support.
