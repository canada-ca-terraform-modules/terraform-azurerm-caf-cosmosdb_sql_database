# terraform-azurerm-caf-cosmosdb_sql_databaseV2

Manages a CosmosDB SQL Database within a Cosmos DB Account, following the SSC Cloud Adoption Framework (CAF) naming and tagging standard.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cosmosdb_account.cosmosdb_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_cosmosdb_sql_database.cosmosdb-sql-database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cosmosdb_sql_database_config"></a> [cosmosdb\_sql\_database\_config](#input\_cosmosdb\_sql\_database\_config) | Object containing all CosmosDB SQL Database configuration parameters | `any` | `{}` | no |
| <a name="input_env"></a> [env](#input\_env) | (Required) 4-character GC governance prefix: <dept(2)><env(1)><region(1)> e.g. ScPc = SSC Production Azure Canada Central | `string` | n/a | yes |
| <a name="input_group"></a> [group](#input\_group) | (Required) Character string defining the group for the target subscription | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure location for the CosmosDB SQL Database | `string` | `"canadacentral"` | no |
| <a name="input_project"></a> [project](#input\_project) | (Required) Character string defining the project for the target subscription | `string` | n/a | yes |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | (Required) Resource group object map | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags that will be applied to every associated resource | `map(string)` | `{}` | no |
| <a name="input_userDefinedString"></a> [userDefinedString](#input\_userDefinedString) | (Required) User defined portion of the CosmosDB SQL Database name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cosmosdb_account_id"></a> [cosmosdb\_account\_id](#output\_cosmosdb\_account\_id) | Outputs the id of the CosmosDB Account |
| <a name="output_cosmosdb_sql_database_id"></a> [cosmosdb\_sql\_database\_id](#output\_cosmosdb\_sql\_database\_id) | Outputs the id of the CosmosDB SQL Database |
| <a name="output_cosmosdb_sql_database_name"></a> [cosmosdb\_sql\_database\_name](#output\_cosmosdb\_sql\_database\_name) | Outputs the name of the CosmosDB SQL Database |
| <a name="output_cosmosdb_sql_database_object"></a> [cosmosdb\_sql\_database\_object](#output\_cosmosdb\_sql\_database\_object) | Outputs the entire CosmosDB SQL Database object |
<!-- END_TF_DOCS -->

### `cosmosdb_sql_database_config` object

| Field | Description | Type | Default | Required |
|-------|-------------|------|---------|:--------:|
| serverType | 3-char SACM device type code (e.g. `CPS`) | `string` | n/a | yes |
| resource\_group | Key in `resource_groups` map, or full Azure resource ID | `string` | n/a | yes |
| account\_name | Name of the CosmosDB account that will host this database | `string` | n/a | yes |
| name | Override the auto-generated database name | `string` | generated | no |
| throughput | Manual throughput in RU/s (min 400, increments of 100). Conflicts with `autoscale_settings`. Must be set on creation. | `number` | `null` | no |
| autoscale\_settings | Autoscale throughput block. Conflicts with `throughput`. Must be set on creation. | `object` | `null` | no |
| autoscale\_settings.max\_throughput | Max RU/s: 1,000–1,000,000 in increments of 1,000 | `number` | `null` | no |

## Usage

### ESLZ module block

```hcl
module "cosmosdb_sql_databases" {
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-cosmosdb_sql_databaseV2.git?ref=v2.0.0"
  for_each = var.cosmosdb_sql_databases

  env                          = var.env
  group                        = var.group
  project                      = var.project
  userDefinedString            = each.key
  location                     = var.location
  tags                         = var.tags
  resource_groups              = local.resource_groups
  cosmosdb_sql_database_config = each.value
}
```

### tfvars example — minimal

```hcl
cosmosdb_sql_databases = {
  mydb = {
    serverType   = "CPS"
    resource_group = "Project"
    account_name   = "my-cosmosdb-account"
  }
}
```

### tfvars example — manual throughput

```hcl
cosmosdb_sql_databases = {
  mydb = {
    serverType     = "CPS"
    resource_group = "Project"
    account_name   = "my-cosmosdb-account"
    throughput     = 400
  }
}
```

### tfvars example — autoscale

```hcl
cosmosdb_sql_databases = {
  mydb = {
    serverType     = "CPS"
    resource_group = "Project"
    account_name   = "my-cosmosdb-account"
    autoscale_settings = {
      max_throughput = 4000
    }
  }
}
```

## Naming convention

The database name is auto-generated as:

```
{env[0:4]}{serverType[0:3]}-{userDefinedString[0:7]}-sdb
```

Example: `env = "Dev1"`, `serverType = "CPS"`, `userDefinedString = "mydb"` → `Dev1CPS-mydb-sdb`

To use a custom name, set `cosmosdb_sql_database_config.name`.

## Notes

- **Throughput mode is immutable after creation.** Switching between manual throughput and autoscale requires a destroy-apply.
- **Do not set `throughput`** when the CosmosDB account has the `EnableServerless` capability.
- `throughput` and `autoscale_settings` are mutually exclusive.
