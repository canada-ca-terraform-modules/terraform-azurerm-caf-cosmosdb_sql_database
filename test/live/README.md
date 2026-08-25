# `test/live/` - live-test harness

A live, real-Azure-resource harness used by the `live-test` PR check to
prove that an open PR doesn't destroy or replace a resource a real consumer
already has running. It is **not** a substitute for either of the module's
other two test surfaces:

- **`tests/*.tftest.hcl`** - mock-based unit tests (`terraform test`, no
  provider credentials, no live Azure resources). Run these first; they're
  fast and free.
- **`ESLZ/`** - a usage example showing the map-based (`for_each`) blueprint
  pattern consumers actually wire this module into. Not exercised by CI at
  all; documentation only.
- **`test/live/`** (this directory) - a single, real instance of the module
  applied against a disposable Azure sandbox subscription. Used by CI to
  diff the PR's plan against a live baseline, and can be run manually by a
  maintainer the same way.

## What's here

| File | Purpose |
|---|---|
| `main.tf` | Module block with `source = "../../"` (a relative path, not a pinned `?ref` - "baseline" and "PR" are just two on-disk checkouts of this repo), the `azurerm` provider config, and an empty `backend "local" {}` block (path supplied at `init` time - see below). |
| `test_dependencies.tf` | A dedicated, throwaway resource group this harness owns outright - never a shared/production resource group. Its name is suffixed with `var.pr_number` so concurrently open PRs never collide. |
| `variables.tf` | `env`, `location` (defaults to `canadacentral`), `tags`, `pr_number` (defaults to `"manual"`), and `cosmosdb_sql_database_config` (typed `any`, passed through to the module with `account_name` suffixed by `pr_number`). |
| `config/cosmosdb_sql_database.tfvars` | One representative real-usage fixture: manual throughput, no autoscale, no `for_each` fan-out. |

No Terragrunt anywhere under this directory - a single harness per repo has
no cross-harness DRY need.

## Running it manually

Requires your own `az login` session against the sandbox subscription (CI
uses OIDC instead).

```bash
cd test/live
terraform init
terraform plan  -var-file=config/cosmosdb_sql_database.tfvars
terraform apply -var-file=config/cosmosdb_sql_database.tfvars
```

Confirm only the live-test resource group and `module.cosmosdb_sql_database`
are planned/applied, then tear it down:

```bash
terraform destroy -var-file=config/cosmosdb_sql_database.tfvars
```

No `.tfstate` file is ever committed under `test/live/` - every run is
fully ephemeral, whether run by CI or by hand.

## Two-checkout state isolation (baseline vs. PR)

CI proves a PR isn't a breaking change by applying the target branch as a
live baseline, then plan/apply-ing the PR branch's checkout of this same
harness against that same live state - two on-disk checkouts of this repo,
one shared external state file, no state copying between them. `pr_number`
(`TF_VAR_pr_number` in CI, sourced from `github.event.number`) suffixes
every `test_dependencies.tf` resource name and the CosmosDB account name, so
two concurrently open PRs against this module never collide on the same
sandbox subscription.
