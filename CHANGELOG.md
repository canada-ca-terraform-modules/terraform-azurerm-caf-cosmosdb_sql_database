# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.0.0] - 2026-08-11

### Changed

- **BREAKING**: Bumped `azurerm` provider constraint from `~> 4.0` to `~> 5.0` (target
  version `5.0.1`). Released as a major version bump, not minor, because it forces every
  consumer of this module to also raise their own root `azurerm` constraint to `~> 5.0` —
  a consumer-facing breaking change to this module's dependency contract, per
  [SemVer](https://semver.org/#spec-item-8), even though no resource arguments changed.
- Bumped `ESLZ/CosmosDbSqlDatabase.tf` module `ref=` from `v1.0.0` to `v2.0.0`.

### Added

- `.github/workflows/documentation.yml` — auto-generates README via terraform-docs on PR.
  Skips the write-back step on fork PRs (`pull_request.head.repo.full_name !=
  github.repository`), since a fork's `GITHUB_TOKEN` has no push access to push commits
  back to the fork branch.
- `.github/workflows/terraform-ci.yml` — fmt/init/validate/test/tflint CI pipeline.
- `.github/workflows/release.yml` — creates a GitHub release on merge to `main`, tagged
  from `ESLZ/CosmosDbSqlDatabase.tf`'s own `?ref=vX.Y.Z`.
- `tests/upgrade_compat.tftest.hcl` — proves a pre-upgrade-shaped `cosmosdb_sql_database_config`
  still applies cleanly, and stays in-place (no `-/+` replace), when re-planned with an
  additional optional argument under this module's *current* (now `~> 5.0`-pinned) provider
  schema. This does **not** by itself prove real 4.x-state → 5.x-provider migration — both
  `terraform test` runs resolve against whatever single provider version this repo's own
  `providers.tf` pins (now 5.0.1); it cannot mix two provider major versions in one test
  file. The actual 4.x → 5.x live-state migration is verified separately by a two-phase
  `terraform-module-upgrade-probe` run (baseline apply under azurerm 4.81.0, then a second
  plan against the same state under this upgraded code/azurerm 5.0.1) against a real
  Azure subscription.

### Notes

- No breaking changes in azurerm 5.0 affect `azurerm_cosmosdb_sql_database` — this resource
  is not listed in the [5.0 upgrade guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/5.0-upgrade-guide)'s breaking-changes sections.
- `azurerm_cosmosdb_account` breaking changes in 5.0 (`local_authentication_disabled` →
  `local_authentication_enabled`, `managed_hsm_key_id` → `key_vault_key_id`,
  `minimal_tls_version` no longer accepting `Tls`/`Tls11`, `ip_range_filter` type change
  string → list) do not affect this module — none of those arguments are exposed or set
  by `module.tf`'s `azurerm_cosmosdb_account` block.
- Existing `ESLZ/*.tfvars` and `cosmosdb_sql_database_config` inputs require no changes to
  produce an identical plan after this upgrade — only the consumer's own root `azurerm`
  provider constraint needs to change.

### Known blockers

- None.

## [1.0.0] - Initial release

- Initial module release: `azurerm_cosmosdb_account` + `azurerm_cosmosdb_sql_database`,
  SSC CAF naming convention, manual throughput / autoscale settings support.
