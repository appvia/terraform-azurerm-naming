<!-- markdownlint-disable -->

<a href="https://www.appvia.io/"><img src="https://raw.githubusercontent.com/appvia/terraform-azurerm-naming/refs/heads/main/docs/banner.jpg" alt="Appvia Banner"/></a><br/><p align="right"> </a> <a href="https://registry.terraform.io/modules/appvia/naming/azurerm/latest"><img src="https://img.shields.io/static/v1?label=APPVIA&message=Terraform%20Registry&color=191970&style=for-the-badge" alt="Terraform Registry"/></a> <a href="https://github.com/appvia/terraform-azurerm-naming/releases/latest"><img src="https://img.shields.io/github/release/appvia/terraform-azurerm-naming.svg?style=for-the-badge&color=006400" alt="Latest Release"/></a> <a href="https://appvia-community.slack.com/join/shared_invite/zt-1s7i7xy85-T155drryqU56emm09ojMVA#/shared-invite/email"><img src="https://img.shields.io/badge/Slack-Join%20Community-purple?style=for-the-badge&logo=slack" alt="Slack Community"/></a> <a href="https://github.com/appvia/terraform-azurerm-naming/graphs/contributors"><img src="https://img.shields.io/github/contributors/appvia/terraform-azurerm-naming.svg?style=for-the-badge&color=FF8C00" alt="Contributors"/></a>

<!-- markdownlint-restore -->
<!--
  ***** CAUTION: Banner URLs are managed by scripts/init-from-template.sh ******
-->

![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform Azurerm Naming

## Description

Terraform module for generating consistent, compliant Azure resource names following the [Microsoft Cloud Adoption Framework (CAF)](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations) abbreviation conventions.

## Features

- **CAF-aligned abbreviations** for 200+ Azure resource types, sourced directly from Microsoft's documentation
- **Naming validation** against Azure's published [resource naming rules](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules) (regex, min/max length)
- **Smart truncation** that equally shortens prefix and suffix elements when names exceed a resource's max length, rather than blindly cutting from the end
- **Short variant support** via `suffix_short` / `prefix_short` for deterministic fallback names
- **Slug overrides** to customise abbreviations per resource type
- **Unique name generation** with configurable length and deterministic seeding
- **Data-driven design** using JSON definitions, refreshable from Azure docs via a bundled Python script

## Usage

```hcl
module "naming" {
  source = "Appvia/naming/azurerm"
  suffix = ["dev", "uks"]
}

resource "azurerm_resource_group" "example" {
  name     = module.naming.resource_group.name      # "rg-dev-uks"
  location = "uksouth"
}

resource "azurerm_virtual_network" "example" {
  name                = module.naming.virtual_network.name  # "vnet-dev-uks"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_storage_account" "example" {
  name                = module.naming.storage_account.name_unique  # "stdevuks<unique>"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

### With short variants for tight name limits

```hcl
module "naming" {
  source = "Appvia/naming/azurerm"

  suffix       = ["development", "uksouth"]
  suffix_short = ["dev", "uks"]
}

# Resources with generous max_length use the full names:
#   module.naming.virtual_network.name => "vnet-development-uksouth"
#
# Resources with tight limits (e.g. key_vault max 24) fall back to short variants:
#   module.naming.key_vault.name => "kv-dev-uks"
#
# If even short variants are too long, elements are equally truncated to fit.
```

### With slug overrides

```hcl
module "naming" {
  source = "Appvia/naming/azurerm"

  suffix         = ["dev", "uks"]
  slug_overrides = {
    container_registry = "acr"
    virtual_network    = "network"
  }
}

# module.naming.container_registry.name => "acrdevuks"
# module.naming.virtual_network.name    => "network-dev-uks"
```

### With unique names for globally-scoped resources

```hcl
module "naming" {
  source = "Appvia/naming/azurerm"

  suffix        = ["prod", "uks"]
  unique_length = 6
}

# module.naming.storage_account.name_unique => "stproduksabc123"
# module.naming.key_vault.name_unique       => "kv-prod-uks-abc123"

# Store the seed to reproduce the same unique names across runs:
output "naming_seed" {
  value = module.naming.unique_seed
}
```

### Accessing the full resources map

```hcl
# All resources are available via the resources output:
module.naming.resources["virtual_network"].name
module.naming.resources["storage_account"].name_unique

# Or use convenience outputs directly:
module.naming.virtual_network.name
module.naming.storage_account.name_unique
```

### Checking name validity

```hcl
# Each resource output includes validation booleans:
module.naming.storage_account.valid_name        # true/false
module.naming.storage_account.valid_name_unique  # true/false
```

## How it works

### Name construction

Names are assembled from components in this order:

```
[prefix...] + slug + [suffix...] + [unique]
```

- Resources with `dashes = true`: components are joined with `-` (e.g., `contoso-vnet-dev-eus2`)
- Resources with `dashes = false`: components are lowercased and concatenated (e.g., `contosoststdeveus2`)

### Smart truncation

When the assembled name exceeds a resource's `max_length`, the module applies truncation in three tiers:

1. **Full name fits?** Use it as-is.
2. **Short variants fit?** Swap `prefix_short`/`suffix_short` in and use those.
3. **Still too long?** Equally truncate all prefix and suffix elements to fit within the budget. The slug and unique string are never truncated.

The equal truncation algorithm:
```
available = max_length - len(slug) - len(unique) - separators
per_element_budget = floor(available / number_of_elements)
each element = substr(element, 0, budget)
```

### Override priority

The module applies three layers of configuration, from lowest to highest priority:

| Priority | Source | What it controls |
|---|---|---|
| 1 (base) | `resource_definitions.json` | Auto-generated baseline from Azure docs |
| 2 (override) | `resource_overrides.json` | Persistent local corrections (any field) |
| 3 (runtime) | `var.slug_overrides` | Slug-only customisation by module consumers |

### Output structure

Each resource output is a map with these fields:

| Field | Type | Description |
|---|---|---|
| `name` | `string` | Generated name without uniqueness suffix |
| `name_unique` | `string` | Generated name with random unique suffix |
| `slug` | `string` | The abbreviation used (e.g., `vnet`, `st`) |
| `min_length` | `number` | Azure's minimum name length |
| `max_length` | `number` | Azure's maximum name length |
| `scope` | `string` | Uniqueness scope (e.g., `resource group`, `global`) |
| `regex` | `string` | Azure's naming validation regex |
| `dashes` | `bool` | Whether hyphens are allowed |
| `valid_name` | `bool` | Whether `name` passes validation |
| `valid_name_unique` | `bool` | Whether `name_unique` passes validation |

## Maintaining resource definitions

### Refreshing from Azure docs

The bundled Python script fetches the latest data from Microsoft's documentation.
Using [uv](https://docs.astral.sh/uv/), dependencies are handled automatically:

```bash
uv run scripts/generate_definitions.py
```

> **Note:** The script also works with plain `python` if dependencies are already installed:
> `pip install requests beautifulsoup4 && python scripts/generate_definitions.py`

This script:
1. Fetches the [CAF resource abbreviations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations) page
2. Fetches the [Azure resource naming rules](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules) page
3. Cross-references and merges the two datasets
4. Applies any entries from `resource_overrides.json` on top
5. Writes `resource_definitions.json` and `exceptions.md`

### Adding or correcting resource definitions

Add entries to `resource_overrides.json`. This file is version-controlled and survives script regeneration:

```json
{
  "my_custom_resource": {
    "slug": "mcr",
    "min_length": 3,
    "max_length": 63,
    "regex": "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$",
    "scope": "resource group",
    "dashes": true,
    "resource_type": "Microsoft.Example/resources"
  }
}
```

Overrides are applied in two places:
- **By the Python script** when regenerating `resource_definitions.json`
- **By Terraform at plan time** so corrections take effect immediately without re-running the script

To correct an existing resource, only include the fields you want to change:

```json
{
  "storage_account": {
    "regex": "^[a-z0-9]{3,24}$"
  }
}
```

### Exceptions

Resources that couldn't be automatically matched to Azure naming rules are listed in `exceptions.md`. As you add corrections to `resource_overrides.json`, they drop off the exceptions list on the next script run.

## Testing

The module includes comprehensive tests using Terraform's native test framework:

```bash
terraform init
terraform test
```

| Test File | Coverage |
|---|---|
| `tests/basic.tftest.hcl` | Core naming: suffix-only, prefix-only, prefix+suffix, slug-only, output structure |
| `tests/truncation.tftest.hcl` | Smart truncation: max_length respected, slug preserved, equal truncation, short variants, all resources checked |
| `tests/validation.tftest.hcl` | Regex validation, valid_name correctness, truncated names still valid |
| `tests/overrides.tftest.hcl` | Slug overrides: applied correctly, non-overridden unchanged, multiple overrides |
| `tests/unique.tftest.hcl` | Unique names: deterministic seed, length control, max_length respected |


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_string.first_letter](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.main](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | List of prefix components prepended to resource names. | `list(string)` | `[]` | no |
| <a name="input_prefix_short"></a> [prefix\_short](#input\_prefix\_short) | Short alternatives for prefix elements, used when the full name exceeds a resource's max length. Must be the same length as prefix if provided. | `list(string)` | `null` | no |
| <a name="input_slug_overrides"></a> [slug\_overrides](#input\_slug\_overrides) | Override default slugs for specific resource types. Keys must match resource definition keys. Example: { container\_registry = "acr" } | `map(string)` | `{}` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | List of suffix components appended to resource names. | `list(string)` | `[]` | no |
| <a name="input_suffix_short"></a> [suffix\_short](#input\_suffix\_short) | Short alternatives for suffix elements, used when the full name exceeds a resource's max length. Must be the same length as suffix if provided. | `list(string)` | `null` | no |
| <a name="input_unique_include_numbers"></a> [unique\_include\_numbers](#input\_unique\_include\_numbers) | Whether to include numbers in the unique suffix. | `bool` | `true` | no |
| <a name="input_unique_length"></a> [unique\_length](#input\_unique\_length) | Length of the unique suffix appended to name\_unique variants. | `number` | `4` | no |
| <a name="input_unique_seed"></a> [unique\_seed](#input\_unique\_seed) | Custom seed for unique string generation. If empty, a random value is used. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ai_search"></a> [ai\_search](#output\_ai\_search) | Ai Search naming outputs. |
| <a name="output_aks_cluster"></a> [aks\_cluster](#output\_aks\_cluster) | Aks Cluster naming outputs. |
| <a name="output_aks_system_node_pool"></a> [aks\_system\_node\_pool](#output\_aks\_system\_node\_pool) | Aks System Node Pool naming outputs. |
| <a name="output_aks_user_node_pool"></a> [aks\_user\_node\_pool](#output\_aks\_user\_node\_pool) | Aks User Node Pool naming outputs. |
| <a name="output_api_management_service_instance"></a> [api\_management\_service\_instance](#output\_api\_management\_service\_instance) | Api Management Service Instance naming outputs. |
| <a name="output_app_configuration_store"></a> [app\_configuration\_store](#output\_app\_configuration\_store) | App Configuration Store naming outputs. |
| <a name="output_app_service_environment"></a> [app\_service\_environment](#output\_app\_service\_environment) | App Service Environment naming outputs. |
| <a name="output_app_service_plan"></a> [app\_service\_plan](#output\_app\_service\_plan) | App Service Plan naming outputs. |
| <a name="output_application_gateway"></a> [application\_gateway](#output\_application\_gateway) | Application Gateway naming outputs. |
| <a name="output_application_insights"></a> [application\_insights](#output\_application\_insights) | Application Insights naming outputs. |
| <a name="output_application_security_group"></a> [application\_security\_group](#output\_application\_security\_group) | Application Security Group naming outputs. |
| <a name="output_automation_account"></a> [automation\_account](#output\_automation\_account) | Automation Account naming outputs. |
| <a name="output_availability_set"></a> [availability\_set](#output\_availability\_set) | Availability Set naming outputs. |
| <a name="output_azure_ai_video_indexer"></a> [azure\_ai\_video\_indexer](#output\_azure\_ai\_video\_indexer) | Azure Ai Video Indexer naming outputs. |
| <a name="output_azure_analysis_services_server"></a> [azure\_analysis\_services\_server](#output\_azure\_analysis\_services\_server) | Azure Analysis Services Server naming outputs. |
| <a name="output_azure_arc_enabled_kubernetes_cluster"></a> [azure\_arc\_enabled\_kubernetes\_cluster](#output\_azure\_arc\_enabled\_kubernetes\_cluster) | Azure Arc Enabled Kubernetes Cluster naming outputs. |
| <a name="output_azure_arc_enabled_server"></a> [azure\_arc\_enabled\_server](#output\_azure\_arc\_enabled\_server) | Azure Arc Enabled Server naming outputs. |
| <a name="output_azure_arc_gateway"></a> [azure\_arc\_gateway](#output\_azure\_arc\_gateway) | Azure Arc Gateway naming outputs. |
| <a name="output_azure_arc_private_link_scope"></a> [azure\_arc\_private\_link\_scope](#output\_azure\_arc\_private\_link\_scope) | Azure Arc Private Link Scope naming outputs. |
| <a name="output_azure_backup_resource_guard"></a> [azure\_backup\_resource\_guard](#output\_azure\_backup\_resource\_guard) | Azure Backup Resource Guard naming outputs. |
| <a name="output_azure_bastion"></a> [azure\_bastion](#output\_azure\_bastion) | Azure Bastion naming outputs. |
| <a name="output_azure_cosmos_db_database"></a> [azure\_cosmos\_db\_database](#output\_azure\_cosmos\_db\_database) | Azure Cosmos Db Database naming outputs. |
| <a name="output_azure_cosmos_db_for_apache_cassandra_account"></a> [azure\_cosmos\_db\_for\_apache\_cassandra\_account](#output\_azure\_cosmos\_db\_for\_apache\_cassandra\_account) | Azure Cosmos Db For Apache Cassandra Account naming outputs. |
| <a name="output_azure_cosmos_db_for_apache_gremlin_account"></a> [azure\_cosmos\_db\_for\_apache\_gremlin\_account](#output\_azure\_cosmos\_db\_for\_apache\_gremlin\_account) | Azure Cosmos Db For Apache Gremlin Account naming outputs. |
| <a name="output_azure_cosmos_db_for_mongodb_account"></a> [azure\_cosmos\_db\_for\_mongodb\_account](#output\_azure\_cosmos\_db\_for\_mongodb\_account) | Azure Cosmos Db For Mongodb Account naming outputs. |
| <a name="output_azure_cosmos_db_for_nosql_account"></a> [azure\_cosmos\_db\_for\_nosql\_account](#output\_azure\_cosmos\_db\_for\_nosql\_account) | Azure Cosmos Db For Nosql Account naming outputs. |
| <a name="output_azure_cosmos_db_for_table_account"></a> [azure\_cosmos\_db\_for\_table\_account](#output\_azure\_cosmos\_db\_for\_table\_account) | Azure Cosmos Db For Table Account naming outputs. |
| <a name="output_azure_cosmos_db_postgresql_cluster"></a> [azure\_cosmos\_db\_postgresql\_cluster](#output\_azure\_cosmos\_db\_postgresql\_cluster) | Azure Cosmos Db Postgresql Cluster naming outputs. |
| <a name="output_azure_data_explorer_cluster"></a> [azure\_data\_explorer\_cluster](#output\_azure\_data\_explorer\_cluster) | Azure Data Explorer Cluster naming outputs. |
| <a name="output_azure_data_explorer_cluster_database"></a> [azure\_data\_explorer\_cluster\_database](#output\_azure\_data\_explorer\_cluster\_database) | Azure Data Explorer Cluster Database naming outputs. |
| <a name="output_azure_data_factory"></a> [azure\_data\_factory](#output\_azure\_data\_factory) | Azure Data Factory naming outputs. |
| <a name="output_azure_databricks_access_connector"></a> [azure\_databricks\_access\_connector](#output\_azure\_databricks\_access\_connector) | Azure Databricks Access Connector naming outputs. |
| <a name="output_azure_databricks_workspace"></a> [azure\_databricks\_workspace](#output\_azure\_databricks\_workspace) | Azure Databricks Workspace naming outputs. |
| <a name="output_azure_digital_twin_instance"></a> [azure\_digital\_twin\_instance](#output\_azure\_digital\_twin\_instance) | Azure Digital Twin Instance naming outputs. |
| <a name="output_azure_load_testing_instance"></a> [azure\_load\_testing\_instance](#output\_azure\_load\_testing\_instance) | Azure Load Testing Instance naming outputs. |
| <a name="output_azure_machine_learning_workspace"></a> [azure\_machine\_learning\_workspace](#output\_azure\_machine\_learning\_workspace) | Azure Machine Learning Workspace naming outputs. |
| <a name="output_azure_managed_grafana"></a> [azure\_managed\_grafana](#output\_azure\_managed\_grafana) | Azure Managed Grafana naming outputs. |
| <a name="output_azure_managed_redis"></a> [azure\_managed\_redis](#output\_azure\_managed\_redis) | Azure Managed Redis naming outputs. |
| <a name="output_azure_migrate_project"></a> [azure\_migrate\_project](#output\_azure\_migrate\_project) | Azure Migrate Project naming outputs. |
| <a name="output_azure_monitor_action_group"></a> [azure\_monitor\_action\_group](#output\_azure\_monitor\_action\_group) | Azure Monitor Action Group naming outputs. |
| <a name="output_azure_monitor_alert_processing_rule"></a> [azure\_monitor\_alert\_processing\_rule](#output\_azure\_monitor\_alert\_processing\_rule) | Azure Monitor Alert Processing Rule naming outputs. |
| <a name="output_azure_monitor_data_collection_rule"></a> [azure\_monitor\_data\_collection\_rule](#output\_azure\_monitor\_data\_collection\_rule) | Azure Monitor Data Collection Rule naming outputs. |
| <a name="output_azure_openai_service"></a> [azure\_openai\_service](#output\_azure\_openai\_service) | Azure Openai Service naming outputs. |
| <a name="output_azure_sql_database"></a> [azure\_sql\_database](#output\_azure\_sql\_database) | Azure Sql Database naming outputs. |
| <a name="output_azure_sql_database_server"></a> [azure\_sql\_database\_server](#output\_azure\_sql\_database\_server) | Azure Sql Database Server naming outputs. |
| <a name="output_azure_sql_elastic_job_agent"></a> [azure\_sql\_elastic\_job\_agent](#output\_azure\_sql\_elastic\_job\_agent) | Azure Sql Elastic Job Agent naming outputs. |
| <a name="output_azure_sql_elastic_pool"></a> [azure\_sql\_elastic\_pool](#output\_azure\_sql\_elastic\_pool) | Azure Sql Elastic Pool naming outputs. |
| <a name="output_azure_stream_analytics"></a> [azure\_stream\_analytics](#output\_azure\_stream\_analytics) | Azure Stream Analytics naming outputs. |
| <a name="output_azure_synapse_analytics_private_link_hub"></a> [azure\_synapse\_analytics\_private\_link\_hub](#output\_azure\_synapse\_analytics\_private\_link\_hub) | Azure Synapse Analytics Private Link Hub naming outputs. |
| <a name="output_azure_synapse_analytics_spark_pool"></a> [azure\_synapse\_analytics\_spark\_pool](#output\_azure\_synapse\_analytics\_spark\_pool) | Azure Synapse Analytics Spark Pool naming outputs. |
| <a name="output_azure_synapse_analytics_sql_dedicated_pool"></a> [azure\_synapse\_analytics\_sql\_dedicated\_pool](#output\_azure\_synapse\_analytics\_sql\_dedicated\_pool) | Azure Synapse Analytics Sql Dedicated Pool naming outputs. |
| <a name="output_azure_synapse_analytics_workspaces"></a> [azure\_synapse\_analytics\_workspaces](#output\_azure\_synapse\_analytics\_workspaces) | Azure Synapse Analytics Workspaces naming outputs. |
| <a name="output_backup_vault_name"></a> [backup\_vault\_name](#output\_backup\_vault\_name) | Backup Vault Name naming outputs. |
| <a name="output_backup_vault_policy"></a> [backup\_vault\_policy](#output\_backup\_vault\_policy) | Backup Vault Policy naming outputs. |
| <a name="output_batch_accounts"></a> [batch\_accounts](#output\_batch\_accounts) | Batch Accounts naming outputs. |
| <a name="output_bot_service"></a> [bot\_service](#output\_bot\_service) | Bot Service naming outputs. |
| <a name="output_cdn_endpoint"></a> [cdn\_endpoint](#output\_cdn\_endpoint) | Cdn Endpoint naming outputs. |
| <a name="output_cdn_profile"></a> [cdn\_profile](#output\_cdn\_profile) | Cdn Profile naming outputs. |
| <a name="output_cloud_service"></a> [cloud\_service](#output\_cloud\_service) | Cloud Service naming outputs. |
| <a name="output_communication_services"></a> [communication\_services](#output\_communication\_services) | Communication Services naming outputs. |
| <a name="output_computer_vision"></a> [computer\_vision](#output\_computer\_vision) | Computer Vision naming outputs. |
| <a name="output_connections"></a> [connections](#output\_connections) | Connections naming outputs. |
| <a name="output_container_apps"></a> [container\_apps](#output\_container\_apps) | Container Apps naming outputs. |
| <a name="output_container_apps_environment"></a> [container\_apps\_environment](#output\_container\_apps\_environment) | Container Apps Environment naming outputs. |
| <a name="output_container_apps_job"></a> [container\_apps\_job](#output\_container\_apps\_job) | Container Apps Job naming outputs. |
| <a name="output_container_instance"></a> [container\_instance](#output\_container\_instance) | Container Instance naming outputs. |
| <a name="output_container_registry"></a> [container\_registry](#output\_container\_registry) | Container Registry naming outputs. |
| <a name="output_content_moderator"></a> [content\_moderator](#output\_content\_moderator) | Content Moderator naming outputs. |
| <a name="output_content_safety"></a> [content\_safety](#output\_content\_safety) | Content Safety naming outputs. |
| <a name="output_custom_vision"></a> [custom\_vision](#output\_custom\_vision) | Custom Vision naming outputs. |
| <a name="output_custom_vision_prediction"></a> [custom\_vision\_prediction](#output\_custom\_vision\_prediction) | Custom Vision Prediction naming outputs. |
| <a name="output_custom_vision_training"></a> [custom\_vision\_training](#output\_custom\_vision\_training) | Custom Vision Training naming outputs. |
| <a name="output_data_collection_endpoint"></a> [data\_collection\_endpoint](#output\_data\_collection\_endpoint) | Data Collection Endpoint naming outputs. |
| <a name="output_data_lake_store_account"></a> [data\_lake\_store\_account](#output\_data\_lake\_store\_account) | Data Lake Store Account naming outputs. |
| <a name="output_database_migration_service_instance"></a> [database\_migration\_service\_instance](#output\_database\_migration\_service\_instance) | Database Migration Service Instance naming outputs. |
| <a name="output_deployment_scripts"></a> [deployment\_scripts](#output\_deployment\_scripts) | Deployment Scripts naming outputs. |
| <a name="output_disk_encryption_set"></a> [disk\_encryption\_set](#output\_disk\_encryption\_set) | Disk Encryption Set naming outputs. |
| <a name="output_dns_forwarding_ruleset"></a> [dns\_forwarding\_ruleset](#output\_dns\_forwarding\_ruleset) | Dns Forwarding Ruleset naming outputs. |
| <a name="output_dns_private_resolver"></a> [dns\_private\_resolver](#output\_dns\_private\_resolver) | Dns Private Resolver naming outputs. |
| <a name="output_dns_private_resolver_inbound_endpoint"></a> [dns\_private\_resolver\_inbound\_endpoint](#output\_dns\_private\_resolver\_inbound\_endpoint) | Dns Private Resolver Inbound Endpoint naming outputs. |
| <a name="output_dns_private_resolver_outbound_endpoint"></a> [dns\_private\_resolver\_outbound\_endpoint](#output\_dns\_private\_resolver\_outbound\_endpoint) | Dns Private Resolver Outbound Endpoint naming outputs. |
| <a name="output_document_intelligence"></a> [document\_intelligence](#output\_document\_intelligence) | Document Intelligence naming outputs. |
| <a name="output_event_grid_domain"></a> [event\_grid\_domain](#output\_event\_grid\_domain) | Event Grid Domain naming outputs. |
| <a name="output_event_grid_namespace"></a> [event\_grid\_namespace](#output\_event\_grid\_namespace) | Event Grid Namespace naming outputs. |
| <a name="output_event_grid_subscriptions"></a> [event\_grid\_subscriptions](#output\_event\_grid\_subscriptions) | Event Grid Subscriptions naming outputs. |
| <a name="output_event_grid_system_topic"></a> [event\_grid\_system\_topic](#output\_event\_grid\_system\_topic) | Event Grid System Topic naming outputs. |
| <a name="output_event_grid_topic"></a> [event\_grid\_topic](#output\_event\_grid\_topic) | Event Grid Topic naming outputs. |
| <a name="output_event_hub"></a> [event\_hub](#output\_event\_hub) | Event Hub naming outputs. |
| <a name="output_event_hubs_namespace"></a> [event\_hubs\_namespace](#output\_event\_hubs\_namespace) | Event Hubs Namespace naming outputs. |
| <a name="output_expressroute_circuit"></a> [expressroute\_circuit](#output\_expressroute\_circuit) | Expressroute Circuit naming outputs. |
| <a name="output_expressroute_direct"></a> [expressroute\_direct](#output\_expressroute\_direct) | Expressroute Direct naming outputs. |
| <a name="output_expressroute_gateway"></a> [expressroute\_gateway](#output\_expressroute\_gateway) | Expressroute Gateway naming outputs. |
| <a name="output_fabric_capacity"></a> [fabric\_capacity](#output\_fabric\_capacity) | Fabric Capacity naming outputs. |
| <a name="output_face_api"></a> [face\_api](#output\_face\_api) | Face Api naming outputs. |
| <a name="output_file_share"></a> [file\_share](#output\_file\_share) | File Share naming outputs. |
| <a name="output_firewall"></a> [firewall](#output\_firewall) | Firewall naming outputs. |
| <a name="output_firewall_policy"></a> [firewall\_policy](#output\_firewall\_policy) | Firewall Policy naming outputs. |
| <a name="output_foundry_account"></a> [foundry\_account](#output\_foundry\_account) | Foundry Account naming outputs. |
| <a name="output_foundry_account_project"></a> [foundry\_account\_project](#output\_foundry\_account\_project) | Foundry Account Project naming outputs. |
| <a name="output_foundry_hub"></a> [foundry\_hub](#output\_foundry\_hub) | Foundry Hub naming outputs. |
| <a name="output_foundry_hub_project"></a> [foundry\_hub\_project](#output\_foundry\_hub\_project) | Foundry Hub Project naming outputs. |
| <a name="output_foundry_tools"></a> [foundry\_tools](#output\_foundry\_tools) | Foundry Tools naming outputs. |
| <a name="output_front_door"></a> [front\_door](#output\_front\_door) | Front Door naming outputs. |
| <a name="output_front_door_endpoint"></a> [front\_door\_endpoint](#output\_front\_door\_endpoint) | Front Door Endpoint naming outputs. |
| <a name="output_front_door_firewall_policy"></a> [front\_door\_firewall\_policy](#output\_front\_door\_firewall\_policy) | Front Door Firewall Policy naming outputs. |
| <a name="output_front_door_profile"></a> [front\_door\_profile](#output\_front\_door\_profile) | Front Door Profile naming outputs. |
| <a name="output_function_app"></a> [function\_app](#output\_function\_app) | Function App naming outputs. |
| <a name="output_gallery"></a> [gallery](#output\_gallery) | Gallery naming outputs. |
| <a name="output_hdinsight_hadoop_cluster"></a> [hdinsight\_hadoop\_cluster](#output\_hdinsight\_hadoop\_cluster) | Hdinsight Hadoop Cluster naming outputs. |
| <a name="output_hdinsight_hbase_cluster"></a> [hdinsight\_hbase\_cluster](#output\_hdinsight\_hbase\_cluster) | Hdinsight Hbase Cluster naming outputs. |
| <a name="output_hdinsight_kafka_cluster"></a> [hdinsight\_kafka\_cluster](#output\_hdinsight\_kafka\_cluster) | Hdinsight Kafka Cluster naming outputs. |
| <a name="output_hdinsight_ml_services_cluster"></a> [hdinsight\_ml\_services\_cluster](#output\_hdinsight\_ml\_services\_cluster) | Hdinsight Ml Services Cluster naming outputs. |
| <a name="output_hdinsight_spark_cluster"></a> [hdinsight\_spark\_cluster](#output\_hdinsight\_spark\_cluster) | Hdinsight Spark Cluster naming outputs. |
| <a name="output_hdinsight_storm_cluster"></a> [hdinsight\_storm\_cluster](#output\_hdinsight\_storm\_cluster) | Hdinsight Storm Cluster naming outputs. |
| <a name="output_health_insights"></a> [health\_insights](#output\_health\_insights) | Health Insights naming outputs. |
| <a name="output_hosting_environment"></a> [hosting\_environment](#output\_hosting\_environment) | Hosting Environment naming outputs. |
| <a name="output_image_template"></a> [image\_template](#output\_image\_template) | Image Template naming outputs. |
| <a name="output_immersive_reader"></a> [immersive\_reader](#output\_immersive\_reader) | Immersive Reader naming outputs. |
| <a name="output_integration_account"></a> [integration\_account](#output\_integration\_account) | Integration Account naming outputs. |
| <a name="output_iot_hub"></a> [iot\_hub](#output\_iot\_hub) | Iot Hub naming outputs. |
| <a name="output_ip_group"></a> [ip\_group](#output\_ip\_group) | Ip Group naming outputs. |
| <a name="output_key_vault"></a> [key\_vault](#output\_key\_vault) | Key Vault naming outputs. |
| <a name="output_key_vault_managed_hsm"></a> [key\_vault\_managed\_hsm](#output\_key\_vault\_managed\_hsm) | Key Vault Managed Hsm naming outputs. |
| <a name="output_language_service"></a> [language\_service](#output\_language\_service) | Language Service naming outputs. |
| <a name="output_load_balancer"></a> [load\_balancer](#output\_load\_balancer) | Load Balancer naming outputs. |
| <a name="output_load_balancer_external"></a> [load\_balancer\_external](#output\_load\_balancer\_external) | Load Balancer External naming outputs. |
| <a name="output_load_balancer_internal"></a> [load\_balancer\_internal](#output\_load\_balancer\_internal) | Load Balancer Internal naming outputs. |
| <a name="output_load_balancer_rule"></a> [load\_balancer\_rule](#output\_load\_balancer\_rule) | Load Balancer Rule naming outputs. |
| <a name="output_local_network_gateway"></a> [local\_network\_gateway](#output\_local\_network\_gateway) | Local Network Gateway naming outputs. |
| <a name="output_log_analytics_query_packs"></a> [log\_analytics\_query\_packs](#output\_log\_analytics\_query\_packs) | Log Analytics Query Packs naming outputs. |
| <a name="output_log_analytics_workspace"></a> [log\_analytics\_workspace](#output\_log\_analytics\_workspace) | Log Analytics Workspace naming outputs. |
| <a name="output_logic_app"></a> [logic\_app](#output\_logic\_app) | Logic App naming outputs. |
| <a name="output_managed_devops_pools"></a> [managed\_devops\_pools](#output\_managed\_devops\_pools) | Managed Devops Pools naming outputs. |
| <a name="output_managed_disk"></a> [managed\_disk](#output\_managed\_disk) | Managed Disk naming outputs. |
| <a name="output_managed_identity"></a> [managed\_identity](#output\_managed\_identity) | Managed Identity naming outputs. |
| <a name="output_management_group"></a> [management\_group](#output\_management\_group) | Management Group naming outputs. |
| <a name="output_maps_account"></a> [maps\_account](#output\_maps\_account) | Maps Account naming outputs. |
| <a name="output_microsoft_purview_instance"></a> [microsoft\_purview\_instance](#output\_microsoft\_purview\_instance) | Microsoft Purview Instance naming outputs. |
| <a name="output_mysql_database"></a> [mysql\_database](#output\_mysql\_database) | Mysql Database naming outputs. |
| <a name="output_nat_gateway"></a> [nat\_gateway](#output\_nat\_gateway) | Nat Gateway naming outputs. |
| <a name="output_network_interface"></a> [network\_interface](#output\_network\_interface) | Network Interface naming outputs. |
| <a name="output_network_security_group"></a> [network\_security\_group](#output\_network\_security\_group) | Network Security Group naming outputs. |
| <a name="output_network_security_group_security_rules"></a> [network\_security\_group\_security\_rules](#output\_network\_security\_group\_security\_rules) | Network Security Group Security Rules naming outputs. |
| <a name="output_network_security_perimeter"></a> [network\_security\_perimeter](#output\_network\_security\_perimeter) | Network Security Perimeter naming outputs. |
| <a name="output_network_watcher"></a> [network\_watcher](#output\_network\_watcher) | Network Watcher naming outputs. |
| <a name="output_notification_hubs"></a> [notification\_hubs](#output\_notification\_hubs) | Notification Hubs naming outputs. |
| <a name="output_notification_hubs_namespace"></a> [notification\_hubs\_namespace](#output\_notification\_hubs\_namespace) | Notification Hubs Namespace naming outputs. |
| <a name="output_postgresql_flexible_server"></a> [postgresql\_flexible\_server](#output\_postgresql\_flexible\_server) | Postgresql Flexible Server naming outputs. |
| <a name="output_power_bi_embedded"></a> [power\_bi\_embedded](#output\_power\_bi\_embedded) | Power Bi Embedded naming outputs. |
| <a name="output_private_endpoint"></a> [private\_endpoint](#output\_private\_endpoint) | Private Endpoint naming outputs. |
| <a name="output_private_link"></a> [private\_link](#output\_private\_link) | Private Link naming outputs. |
| <a name="output_provisioning_services"></a> [provisioning\_services](#output\_provisioning\_services) | Provisioning Services naming outputs. |
| <a name="output_provisioning_services_certificate"></a> [provisioning\_services\_certificate](#output\_provisioning\_services\_certificate) | Provisioning Services Certificate naming outputs. |
| <a name="output_proximity_placement_group"></a> [proximity\_placement\_group](#output\_proximity\_placement\_group) | Proximity Placement Group naming outputs. |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | Public Ip Address naming outputs. |
| <a name="output_public_ip_address_prefix"></a> [public\_ip\_address\_prefix](#output\_public\_ip\_address\_prefix) | Public Ip Address Prefix naming outputs. |
| <a name="output_recovery_services_vault"></a> [recovery\_services\_vault](#output\_recovery\_services\_vault) | Recovery Services Vault naming outputs. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | Resource Group naming outputs. |
| <a name="output_resources"></a> [resources](#output\_resources) | Map of all resource naming outputs. Access via module.naming.resources.resource\_type.name |
| <a name="output_restore_point_collection"></a> [restore\_point\_collection](#output\_restore\_point\_collection) | Restore Point Collection naming outputs. |
| <a name="output_route_filter"></a> [route\_filter](#output\_route\_filter) | Route Filter naming outputs. |
| <a name="output_route_server"></a> [route\_server](#output\_route\_server) | Route Server naming outputs. |
| <a name="output_route_table"></a> [route\_table](#output\_route\_table) | Route Table naming outputs. |
| <a name="output_service_bus_namespace"></a> [service\_bus\_namespace](#output\_service\_bus\_namespace) | Service Bus Namespace naming outputs. |
| <a name="output_service_bus_queue"></a> [service\_bus\_queue](#output\_service\_bus\_queue) | Service Bus Queue naming outputs. |
| <a name="output_service_bus_topic"></a> [service\_bus\_topic](#output\_service\_bus\_topic) | Service Bus Topic naming outputs. |
| <a name="output_service_bus_topic_subscription"></a> [service\_bus\_topic\_subscription](#output\_service\_bus\_topic\_subscription) | Service Bus Topic Subscription naming outputs. |
| <a name="output_service_endpoint_policy"></a> [service\_endpoint\_policy](#output\_service\_endpoint\_policy) | Service Endpoint Policy naming outputs. |
| <a name="output_service_fabric_cluster"></a> [service\_fabric\_cluster](#output\_service\_fabric\_cluster) | Service Fabric Cluster naming outputs. |
| <a name="output_service_fabric_managed_cluster"></a> [service\_fabric\_managed\_cluster](#output\_service\_fabric\_managed\_cluster) | Service Fabric Managed Cluster naming outputs. |
| <a name="output_signalr"></a> [signalr](#output\_signalr) | Signalr naming outputs. |
| <a name="output_snapshot"></a> [snapshot](#output\_snapshot) | Snapshot naming outputs. |
| <a name="output_speech_service"></a> [speech\_service](#output\_speech\_service) | Speech Service naming outputs. |
| <a name="output_sql_managed_instance"></a> [sql\_managed\_instance](#output\_sql\_managed\_instance) | Sql Managed Instance naming outputs. |
| <a name="output_ssh_key"></a> [ssh\_key](#output\_ssh\_key) | Ssh Key naming outputs. |
| <a name="output_static_web_app"></a> [static\_web\_app](#output\_static\_web\_app) | Static Web App naming outputs. |
| <a name="output_storage_account"></a> [storage\_account](#output\_storage\_account) | Storage Account naming outputs. |
| <a name="output_storage_sync_service_name"></a> [storage\_sync\_service\_name](#output\_storage\_sync\_service\_name) | Storage Sync Service Name naming outputs. |
| <a name="output_template_specs_name"></a> [template\_specs\_name](#output\_template\_specs\_name) | Template Specs Name naming outputs. |
| <a name="output_time_series_insights_environment"></a> [time\_series\_insights\_environment](#output\_time\_series\_insights\_environment) | Time Series Insights Environment naming outputs. |
| <a name="output_traffic_manager_profile"></a> [traffic\_manager\_profile](#output\_traffic\_manager\_profile) | Traffic Manager Profile naming outputs. |
| <a name="output_translator"></a> [translator](#output\_translator) | Translator naming outputs. |
| <a name="output_unique_seed"></a> [unique\_seed](#output\_unique\_seed) | The seed used for unique name generation. Store this to reproduce the same unique names. |
| <a name="output_user_defined_route"></a> [user\_defined\_route](#output\_user\_defined\_route) | User Defined Route naming outputs. |
| <a name="output_validation"></a> [validation](#output\_validation) | Validation results for all resource names. |
| <a name="output_virtual_desktop_application_group"></a> [virtual\_desktop\_application\_group](#output\_virtual\_desktop\_application\_group) | Virtual Desktop Application Group naming outputs. |
| <a name="output_virtual_desktop_host_pool"></a> [virtual\_desktop\_host\_pool](#output\_virtual\_desktop\_host\_pool) | Virtual Desktop Host Pool naming outputs. |
| <a name="output_virtual_desktop_scaling_plan"></a> [virtual\_desktop\_scaling\_plan](#output\_virtual\_desktop\_scaling\_plan) | Virtual Desktop Scaling Plan naming outputs. |
| <a name="output_virtual_desktop_workspace"></a> [virtual\_desktop\_workspace](#output\_virtual\_desktop\_workspace) | Virtual Desktop Workspace naming outputs. |
| <a name="output_virtual_machine"></a> [virtual\_machine](#output\_virtual\_machine) | Virtual Machine naming outputs. |
| <a name="output_virtual_machine_maintenance_configuration"></a> [virtual\_machine\_maintenance\_configuration](#output\_virtual\_machine\_maintenance\_configuration) | Virtual Machine Maintenance Configuration naming outputs. |
| <a name="output_virtual_machine_scale_set"></a> [virtual\_machine\_scale\_set](#output\_virtual\_machine\_scale\_set) | Virtual Machine Scale Set naming outputs. |
| <a name="output_virtual_network"></a> [virtual\_network](#output\_virtual\_network) | Virtual Network naming outputs. |
| <a name="output_virtual_network_gateway"></a> [virtual\_network\_gateway](#output\_virtual\_network\_gateway) | Virtual Network Gateway naming outputs. |
| <a name="output_virtual_network_manager"></a> [virtual\_network\_manager](#output\_virtual\_network\_manager) | Virtual Network Manager naming outputs. |
| <a name="output_virtual_network_peering"></a> [virtual\_network\_peering](#output\_virtual\_network\_peering) | Virtual Network Peering naming outputs. |
| <a name="output_virtual_network_subnet"></a> [virtual\_network\_subnet](#output\_virtual\_network\_subnet) | Virtual Network Subnet naming outputs. |
| <a name="output_virtual_wan"></a> [virtual\_wan](#output\_virtual\_wan) | Virtual Wan naming outputs. |
| <a name="output_virtual_wan_hub"></a> [virtual\_wan\_hub](#output\_virtual\_wan\_hub) | Virtual Wan Hub naming outputs. |
| <a name="output_vm_storage_account"></a> [vm\_storage\_account](#output\_vm\_storage\_account) | Vm Storage Account naming outputs. |
| <a name="output_vpn_connection"></a> [vpn\_connection](#output\_vpn\_connection) | Vpn Connection naming outputs. |
| <a name="output_vpn_gateway"></a> [vpn\_gateway](#output\_vpn\_gateway) | Vpn Gateway naming outputs. |
| <a name="output_vpn_site"></a> [vpn\_site](#output\_vpn\_site) | Vpn Site naming outputs. |
| <a name="output_web_app"></a> [web\_app](#output\_web\_app) | Web App naming outputs. |
| <a name="output_web_application_firewall_policy"></a> [web\_application\_firewall\_policy](#output\_web\_application\_firewall\_policy) | Web Application Firewall Policy naming outputs. |
| <a name="output_web_application_firewall_policy_rule_group"></a> [web\_application\_firewall\_policy\_rule\_group](#output\_web\_application\_firewall\_policy\_rule\_group) | Web Application Firewall Policy Rule Group naming outputs. |
| <a name="output_webpubsub"></a> [webpubsub](#output\_webpubsub) | Webpubsub naming outputs. |
<!-- END_TF_DOCS -->

## Contributing

Contributions are welcome. Please read the [Code of Conduct](./CODE_OF_CONDUCT.md) before contributing.

### Project structure

```
terraform-azurerm-naming/
├── main.tf                        # Terraform block and random_string resources
├── variables.tf                   # All input variables
├── locals.tf                      # Core naming logic (truncation, assembly, validation)
├── outputs.tf                     # Individual output per resource (auto-generated)
├── resource_definitions.json      # Auto-generated baseline — DO NOT edit by hand
├── resource_overrides.json        # Manual corrections — this is what you edit
├── exceptions.md                  # Auto-generated list of unmatched resources
├── scripts/
│   └── generate_definitions.py    # Fetches Azure docs and generates definitions
└── tests/
    ├── basic.tftest.hcl
    ├── truncation.tftest.hcl
    ├── validation.tftest.hcl
    ├── overrides.tftest.hcl
    └── unique.tftest.hcl
```

### Understanding the data files

The module uses two JSON files to define resource naming rules:

**`resource_definitions.json`** (auto-generated, do not edit manually)

This file is generated by `scripts/generate_definitions.py` and contains the merged result of Azure docs data plus any overrides. It is the file that Terraform reads at plan time. Running the script will overwrite this file entirely, so manual edits will be lost.

**`resource_overrides.json`** (manually maintained, version-controlled)

This is the file you should edit when you need to:
- Fix an incorrect regex, length limit, or scope for an existing resource
- Add a new resource type that isn't in the CAF abbreviations page
- Correct a slug that was parsed incorrectly from the docs

Partial overrides are supported — you only need to include the fields you want to change:

```json
{
  "storage_account": {
    "regex": "^[a-z0-9]{3,24}$"
  },
  "my_new_resource": {
    "slug": "mnr",
    "min_length": 1,
    "max_length": 63,
    "regex": "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$",
    "scope": "resource group",
    "dashes": true,
    "resource_type": "Microsoft.Example/resources"
  }
}
```

Overrides take effect in two places:
1. When the Python script runs, overrides are merged into the generated `resource_definitions.json`
2. Terraform also reads `resource_overrides.json` directly at plan time, so corrections are applied immediately without needing to re-run the script

### How to add or update a resource

1. **Check `exceptions.md`** to see if the resource is listed as unmatched
2. **Look up the naming rules** in the [Azure resource naming rules documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
3. **Add an entry to `resource_overrides.json`** with the correct constraints
4. **Run `terraform test`** to verify your changes don't break anything
5. **Optionally regenerate** by running `uv run scripts/generate_definitions.py` (or `make generate`) to bake overrides into the baseline and update `exceptions.md`

### How to refresh from Azure docs

When Microsoft updates their documentation (new resources, changed naming rules):

```bash
# Regenerate resource_definitions.json from live Azure docs
# (uv automatically installs dependencies in an ephemeral environment)
uv run scripts/generate_definitions.py

# Or equivalently:
make generate

# Verify everything still works
terraform init
terraform test
```

The script will:
- Fetch the latest CAF abbreviations and naming rules from Microsoft's docs
- Cross-reference and merge the two datasets
- Apply all entries from `resource_overrides.json` on top
- Write the updated `resource_definitions.json` and `exceptions.md`
- Report how many resources matched, how many were resolved by overrides, and how many remain unmatched

### Pull request checklist

- [ ] All changes to resource definitions go in `resource_overrides.json`, not `resource_definitions.json`
- [ ] `terraform fmt -recursive` passes
- [ ] `terraform validate` passes
- [ ] `terraform test` passes (all 30 tests)
- [ ] If adding a new resource, add the corresponding `output` block to `outputs.tf`
- [ ] If changing naming rules, verify the regex against Azure's actual resource naming requirements
- [ ] Update `exceptions.md` by running `uv run scripts/generate_definitions.py` (or `make generate`) if overrides resolve previously unmatched resources

## License

This project is licensed under the terms of the [GPL-3.0 license](./LICENSE).

## Acknowledgements

This module was inspired by [Azure/terraform-azurerm-naming](https://github.com/Azure/terraform-azurerm-naming), originally created by [Dan Wahlin](https://github.com/DanWahlin) and contributors.
