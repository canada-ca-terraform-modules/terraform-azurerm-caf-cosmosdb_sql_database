variable "env" {
  description = "4-character GC governance prefix used in the generated CosmosDB SQL Database name"
  type        = string
  default     = "test"
}

variable "location" {
  description = "Location for the throwaway live-test resource group and the CosmosDB account"
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags applied to the resources created by this harness"
  type        = map(string)
  default = {
    purpose = "module-live-test"
  }
}

variable "pr_number" {
  description = <<-EOT
    Suffix applied to test_dependencies.tf resource names (and the CosmosDB
    account name) so concurrent PRs against this module never collide on the
    same sandbox subscription. CI sources this from `TF_VAR_pr_number`
    (`github.event.number`); manual runs can leave the default or pass their
    own value.
  EOT
  type        = string
  default     = "manual"
}

variable "cosmosdb_sql_database_config" {
  description = "CosmosDB SQL Database configuration object, passed straight through to the module under test"
  type        = any
}
