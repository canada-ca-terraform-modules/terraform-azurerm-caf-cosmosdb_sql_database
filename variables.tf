variable "location" {
  description = "Azure location for the CosmosDB SQL Database"
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags that will be applied to every associated resource"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "(Required) 4-character GC governance prefix: <dept(2)><env(1)><region(1)> e.g. ScPc = SSC Production Azure Canada Central"
  type        = string
}

variable "group" {
  description = "(Required) Character string defining the group for the target subscription"
  type        = string
}

variable "project" {
  description = "(Required) Character string defining the project for the target subscription"
  type        = string
}

variable "userDefinedString" {
  description = "(Required) User defined portion of the CosmosDB SQL Database name"
  type        = string
}

variable "resource_groups" {
  description = "(Required) Resource group object map"
  type        = any
  default     = {}
}

variable "cosmosdb_sql_database_config" {
  description = "Object containing all CosmosDB SQL Database configuration parameters"
  type        = any
  default     = {}
}
