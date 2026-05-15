# terraform-azurerm-caf-cosmosdb_sql_databaseV2

Manages a CosmosDB SQL Database within a Cosmos DB Account, following the SSC Cloud Adoption Framework (CAF) naming and tagging standard.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9 |
| azurerm | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_cosmosdb_sql_database.cosmosdb-sql-database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| env | 4-character GC governance prefix: `<dept(2)><env(1)><region(1)>` e.g. `ScPc` = SSC Production Azure Canada Central | `string` | n/a | yes |
| group | Character string defining the group for the target subscription | `string` | n/a | yes |
| project | Character string defining the project for the target subscription | `string` | n/a | yes |
| userDefinedString | User defined portion of the CosmosDB SQL Database name | `string` | n/a | yes |
| cosmosdb\_sql\_database\_config | Object containing all CosmosDB SQL Database configuration parameters | `any` | `{}` | no |
| location | Azure location for the CosmosDB SQL Database | `string` | `"canadacentral"` | no |
| resource\_groups | Resource group object map | `any` | `{}` | no |
| tags | Tags that will be applied to every associated resource | `map(string)` | `{}` | no |

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

## Outputs

| Name | Description |
|------|-------------|
| cosmosdb\_sql\_database\_id | The ID of the CosmosDB SQL Database |
| cosmosdb\_sql\_database\_name | The name of the CosmosDB SQL Database |
| cosmosdb\_sql\_database\_object | The full CosmosDB SQL Database object (sensitive) |

## Usage

### ESLZ module block

```hcl
module "cosmosdb_sql_databases" {
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-cosmosdb_sql_databaseV2.git?ref=v1.0.0"
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
<!-- END_TF_DOCS -->
