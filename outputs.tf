output "resources" {
  value       = local.resources
  description = "Map of all resource naming outputs. Access via module.naming.resources.resource_type.name"
}

output "validation" {
  value = { for k, v in local.resources : k => {
    valid_name        = v.valid_name
    valid_name_unique = v.valid_name_unique
  } }
  description = "Validation results for all resource names."
}

output "unique_seed" {
  value       = var.unique_seed != "" ? var.unique_seed : local.random_safe
  description = "The seed used for unique name generation. Store this to reproduce the same unique names."
}

output "ai_search" {
  value       = local.resources["ai_search"]
  description = "Ai Search naming outputs."
}

output "aks_cluster" {
  value       = local.resources["aks_cluster"]
  description = "Aks Cluster naming outputs."
}

output "aks_system_node_pool" {
  value       = local.resources["aks_system_node_pool"]
  description = "Aks System Node Pool naming outputs."
}

output "aks_user_node_pool" {
  value       = local.resources["aks_user_node_pool"]
  description = "Aks User Node Pool naming outputs."
}

output "api_management_service_instance" {
  value       = local.resources["api_management_service_instance"]
  description = "Api Management Service Instance naming outputs."
}

output "app_configuration_store" {
  value       = local.resources["app_configuration_store"]
  description = "App Configuration Store naming outputs."
}

output "app_service_environment" {
  value       = local.resources["app_service_environment"]
  description = "App Service Environment naming outputs."
}

output "app_service_plan" {
  value       = local.resources["app_service_plan"]
  description = "App Service Plan naming outputs."
}

output "application_gateway" {
  value       = local.resources["application_gateway"]
  description = "Application Gateway naming outputs."
}

output "application_insights" {
  value       = local.resources["application_insights"]
  description = "Application Insights naming outputs."
}

output "application_security_group" {
  value       = local.resources["application_security_group"]
  description = "Application Security Group naming outputs."
}

output "automation_account" {
  value       = local.resources["automation_account"]
  description = "Automation Account naming outputs."
}

output "availability_set" {
  value       = local.resources["availability_set"]
  description = "Availability Set naming outputs."
}

output "azure_ai_video_indexer" {
  value       = local.resources["azure_ai_video_indexer"]
  description = "Azure Ai Video Indexer naming outputs."
}

output "azure_analysis_services_server" {
  value       = local.resources["azure_analysis_services_server"]
  description = "Azure Analysis Services Server naming outputs."
}

output "azure_arc_enabled_kubernetes_cluster" {
  value       = local.resources["azure_arc_enabled_kubernetes_cluster"]
  description = "Azure Arc Enabled Kubernetes Cluster naming outputs."
}

output "azure_arc_enabled_server" {
  value       = local.resources["azure_arc_enabled_server"]
  description = "Azure Arc Enabled Server naming outputs."
}

output "azure_arc_gateway" {
  value       = local.resources["azure_arc_gateway"]
  description = "Azure Arc Gateway naming outputs."
}

output "azure_arc_private_link_scope" {
  value       = local.resources["azure_arc_private_link_scope"]
  description = "Azure Arc Private Link Scope naming outputs."
}

output "azure_backup_resource_guard" {
  value       = local.resources["azure_backup_resource_guard"]
  description = "Azure Backup Resource Guard naming outputs."
}

output "azure_bastion" {
  value       = local.resources["azure_bastion"]
  description = "Azure Bastion naming outputs."
}

output "azure_cosmos_db_database" {
  value       = local.resources["azure_cosmos_db_database"]
  description = "Azure Cosmos Db Database naming outputs."
}

output "azure_cosmos_db_for_apache_cassandra_account" {
  value       = local.resources["azure_cosmos_db_for_apache_cassandra_account"]
  description = "Azure Cosmos Db For Apache Cassandra Account naming outputs."
}

output "azure_cosmos_db_for_apache_gremlin_account" {
  value       = local.resources["azure_cosmos_db_for_apache_gremlin_account"]
  description = "Azure Cosmos Db For Apache Gremlin Account naming outputs."
}

output "azure_cosmos_db_for_mongodb_account" {
  value       = local.resources["azure_cosmos_db_for_mongodb_account"]
  description = "Azure Cosmos Db For Mongodb Account naming outputs."
}

output "azure_cosmos_db_for_nosql_account" {
  value       = local.resources["azure_cosmos_db_for_nosql_account"]
  description = "Azure Cosmos Db For Nosql Account naming outputs."
}

output "azure_cosmos_db_for_table_account" {
  value       = local.resources["azure_cosmos_db_for_table_account"]
  description = "Azure Cosmos Db For Table Account naming outputs."
}

output "azure_cosmos_db_postgresql_cluster" {
  value       = local.resources["azure_cosmos_db_postgresql_cluster"]
  description = "Azure Cosmos Db Postgresql Cluster naming outputs."
}

output "azure_data_explorer_cluster" {
  value       = local.resources["azure_data_explorer_cluster"]
  description = "Azure Data Explorer Cluster naming outputs."
}

output "azure_data_explorer_cluster_database" {
  value       = local.resources["azure_data_explorer_cluster_database"]
  description = "Azure Data Explorer Cluster Database naming outputs."
}

output "azure_data_factory" {
  value       = local.resources["azure_data_factory"]
  description = "Azure Data Factory naming outputs."
}

output "azure_databricks_access_connector" {
  value       = local.resources["azure_databricks_access_connector"]
  description = "Azure Databricks Access Connector naming outputs."
}

output "azure_databricks_workspace" {
  value       = local.resources["azure_databricks_workspace"]
  description = "Azure Databricks Workspace naming outputs."
}

output "azure_digital_twin_instance" {
  value       = local.resources["azure_digital_twin_instance"]
  description = "Azure Digital Twin Instance naming outputs."
}

output "azure_load_testing_instance" {
  value       = local.resources["azure_load_testing_instance"]
  description = "Azure Load Testing Instance naming outputs."
}

output "azure_machine_learning_workspace" {
  value       = local.resources["azure_machine_learning_workspace"]
  description = "Azure Machine Learning Workspace naming outputs."
}

output "azure_managed_grafana" {
  value       = local.resources["azure_managed_grafana"]
  description = "Azure Managed Grafana naming outputs."
}

output "azure_managed_redis" {
  value       = local.resources["azure_managed_redis"]
  description = "Azure Managed Redis naming outputs."
}

output "azure_migrate_project" {
  value       = local.resources["azure_migrate_project"]
  description = "Azure Migrate Project naming outputs."
}

output "azure_monitor_action_group" {
  value       = local.resources["azure_monitor_action_group"]
  description = "Azure Monitor Action Group naming outputs."
}

output "azure_monitor_alert_processing_rule" {
  value       = local.resources["azure_monitor_alert_processing_rule"]
  description = "Azure Monitor Alert Processing Rule naming outputs."
}

output "azure_monitor_data_collection_rule" {
  value       = local.resources["azure_monitor_data_collection_rule"]
  description = "Azure Monitor Data Collection Rule naming outputs."
}

output "azure_openai_service" {
  value       = local.resources["azure_openai_service"]
  description = "Azure Openai Service naming outputs."
}

output "azure_sql_database" {
  value       = local.resources["azure_sql_database"]
  description = "Azure Sql Database naming outputs."
}

output "azure_sql_database_server" {
  value       = local.resources["azure_sql_database_server"]
  description = "Azure Sql Database Server naming outputs."
}

output "azure_sql_elastic_job_agent" {
  value       = local.resources["azure_sql_elastic_job_agent"]
  description = "Azure Sql Elastic Job Agent naming outputs."
}

output "azure_sql_elastic_pool" {
  value       = local.resources["azure_sql_elastic_pool"]
  description = "Azure Sql Elastic Pool naming outputs."
}

output "azure_stream_analytics" {
  value       = local.resources["azure_stream_analytics"]
  description = "Azure Stream Analytics naming outputs."
}

output "azure_synapse_analytics_private_link_hub" {
  value       = local.resources["azure_synapse_analytics_private_link_hub"]
  description = "Azure Synapse Analytics Private Link Hub naming outputs."
}

output "azure_synapse_analytics_spark_pool" {
  value       = local.resources["azure_synapse_analytics_spark_pool"]
  description = "Azure Synapse Analytics Spark Pool naming outputs."
}

output "azure_synapse_analytics_sql_dedicated_pool" {
  value       = local.resources["azure_synapse_analytics_sql_dedicated_pool"]
  description = "Azure Synapse Analytics Sql Dedicated Pool naming outputs."
}

output "azure_synapse_analytics_workspaces" {
  value       = local.resources["azure_synapse_analytics_workspaces"]
  description = "Azure Synapse Analytics Workspaces naming outputs."
}

output "backup_vault_name" {
  value       = local.resources["backup_vault_name"]
  description = "Backup Vault Name naming outputs."
}

output "backup_vault_policy" {
  value       = local.resources["backup_vault_policy"]
  description = "Backup Vault Policy naming outputs."
}

output "batch_accounts" {
  value       = local.resources["batch_accounts"]
  description = "Batch Accounts naming outputs."
}

output "bot_service" {
  value       = local.resources["bot_service"]
  description = "Bot Service naming outputs."
}

output "cdn_endpoint" {
  value       = local.resources["cdn_endpoint"]
  description = "Cdn Endpoint naming outputs."
}

output "cdn_profile" {
  value       = local.resources["cdn_profile"]
  description = "Cdn Profile naming outputs."
}

output "cloud_service" {
  value       = local.resources["cloud_service"]
  description = "Cloud Service naming outputs."
}

output "communication_services" {
  value       = local.resources["communication_services"]
  description = "Communication Services naming outputs."
}

output "computer_vision" {
  value       = local.resources["computer_vision"]
  description = "Computer Vision naming outputs."
}

output "connections" {
  value       = local.resources["connections"]
  description = "Connections naming outputs."
}

output "container_apps" {
  value       = local.resources["container_apps"]
  description = "Container Apps naming outputs."
}

output "container_apps_environment" {
  value       = local.resources["container_apps_environment"]
  description = "Container Apps Environment naming outputs."
}

output "container_apps_job" {
  value       = local.resources["container_apps_job"]
  description = "Container Apps Job naming outputs."
}

output "container_instance" {
  value       = local.resources["container_instance"]
  description = "Container Instance naming outputs."
}

output "container_registry" {
  value       = local.resources["container_registry"]
  description = "Container Registry naming outputs."
}

output "content_moderator" {
  value       = local.resources["content_moderator"]
  description = "Content Moderator naming outputs."
}

output "content_safety" {
  value       = local.resources["content_safety"]
  description = "Content Safety naming outputs."
}

output "custom_vision" {
  value       = local.resources["custom_vision"]
  description = "Custom Vision naming outputs."
}

output "custom_vision_prediction" {
  value       = local.resources["custom_vision_prediction"]
  description = "Custom Vision Prediction naming outputs."
}

output "custom_vision_training" {
  value       = local.resources["custom_vision_training"]
  description = "Custom Vision Training naming outputs."
}

output "data_collection_endpoint" {
  value       = local.resources["data_collection_endpoint"]
  description = "Data Collection Endpoint naming outputs."
}

output "data_lake_store_account" {
  value       = local.resources["data_lake_store_account"]
  description = "Data Lake Store Account naming outputs."
}

output "database_migration_service_instance" {
  value       = local.resources["database_migration_service_instance"]
  description = "Database Migration Service Instance naming outputs."
}

output "deployment_scripts" {
  value       = local.resources["deployment_scripts"]
  description = "Deployment Scripts naming outputs."
}

output "disk_encryption_set" {
  value       = local.resources["disk_encryption_set"]
  description = "Disk Encryption Set naming outputs."
}

output "dns_forwarding_ruleset" {
  value       = local.resources["dns_forwarding_ruleset"]
  description = "Dns Forwarding Ruleset naming outputs."
}

output "dns_private_resolver" {
  value       = local.resources["dns_private_resolver"]
  description = "Dns Private Resolver naming outputs."
}

output "dns_private_resolver_inbound_endpoint" {
  value       = local.resources["dns_private_resolver_inbound_endpoint"]
  description = "Dns Private Resolver Inbound Endpoint naming outputs."
}

output "dns_private_resolver_outbound_endpoint" {
  value       = local.resources["dns_private_resolver_outbound_endpoint"]
  description = "Dns Private Resolver Outbound Endpoint naming outputs."
}

output "document_intelligence" {
  value       = local.resources["document_intelligence"]
  description = "Document Intelligence naming outputs."
}

output "event_grid_domain" {
  value       = local.resources["event_grid_domain"]
  description = "Event Grid Domain naming outputs."
}

output "event_grid_namespace" {
  value       = local.resources["event_grid_namespace"]
  description = "Event Grid Namespace naming outputs."
}

output "event_grid_subscriptions" {
  value       = local.resources["event_grid_subscriptions"]
  description = "Event Grid Subscriptions naming outputs."
}

output "event_grid_system_topic" {
  value       = local.resources["event_grid_system_topic"]
  description = "Event Grid System Topic naming outputs."
}

output "event_grid_topic" {
  value       = local.resources["event_grid_topic"]
  description = "Event Grid Topic naming outputs."
}

output "event_hub" {
  value       = local.resources["event_hub"]
  description = "Event Hub naming outputs."
}

output "event_hubs_namespace" {
  value       = local.resources["event_hubs_namespace"]
  description = "Event Hubs Namespace naming outputs."
}

output "expressroute_circuit" {
  value       = local.resources["expressroute_circuit"]
  description = "Expressroute Circuit naming outputs."
}

output "expressroute_direct" {
  value       = local.resources["expressroute_direct"]
  description = "Expressroute Direct naming outputs."
}

output "expressroute_gateway" {
  value       = local.resources["expressroute_gateway"]
  description = "Expressroute Gateway naming outputs."
}

output "fabric_capacity" {
  value       = local.resources["fabric_capacity"]
  description = "Fabric Capacity naming outputs."
}

output "face_api" {
  value       = local.resources["face_api"]
  description = "Face Api naming outputs."
}

output "file_share" {
  value       = local.resources["file_share"]
  description = "File Share naming outputs."
}

output "firewall" {
  value       = local.resources["firewall"]
  description = "Firewall naming outputs."
}

output "firewall_policy" {
  value       = local.resources["firewall_policy"]
  description = "Firewall Policy naming outputs."
}

output "foundry_account" {
  value       = local.resources["foundry_account"]
  description = "Foundry Account naming outputs."
}

output "foundry_account_project" {
  value       = local.resources["foundry_account_project"]
  description = "Foundry Account Project naming outputs."
}

output "foundry_hub" {
  value       = local.resources["foundry_hub"]
  description = "Foundry Hub naming outputs."
}

output "foundry_hub_project" {
  value       = local.resources["foundry_hub_project"]
  description = "Foundry Hub Project naming outputs."
}

output "foundry_tools" {
  value       = local.resources["foundry_tools"]
  description = "Foundry Tools naming outputs."
}

output "front_door" {
  value       = local.resources["front_door"]
  description = "Front Door naming outputs."
}

output "front_door_endpoint" {
  value       = local.resources["front_door_endpoint"]
  description = "Front Door Endpoint naming outputs."
}

output "front_door_firewall_policy" {
  value       = local.resources["front_door_firewall_policy"]
  description = "Front Door Firewall Policy naming outputs."
}

output "front_door_profile" {
  value       = local.resources["front_door_profile"]
  description = "Front Door Profile naming outputs."
}

output "function_app" {
  value       = local.resources["function_app"]
  description = "Function App naming outputs."
}

output "gallery" {
  value       = local.resources["gallery"]
  description = "Gallery naming outputs."
}

output "hdinsight_hadoop_cluster" {
  value       = local.resources["hdinsight_hadoop_cluster"]
  description = "Hdinsight Hadoop Cluster naming outputs."
}

output "hdinsight_hbase_cluster" {
  value       = local.resources["hdinsight_hbase_cluster"]
  description = "Hdinsight Hbase Cluster naming outputs."
}

output "hdinsight_kafka_cluster" {
  value       = local.resources["hdinsight_kafka_cluster"]
  description = "Hdinsight Kafka Cluster naming outputs."
}

output "hdinsight_ml_services_cluster" {
  value       = local.resources["hdinsight_ml_services_cluster"]
  description = "Hdinsight Ml Services Cluster naming outputs."
}

output "hdinsight_spark_cluster" {
  value       = local.resources["hdinsight_spark_cluster"]
  description = "Hdinsight Spark Cluster naming outputs."
}

output "hdinsight_storm_cluster" {
  value       = local.resources["hdinsight_storm_cluster"]
  description = "Hdinsight Storm Cluster naming outputs."
}

output "health_insights" {
  value       = local.resources["health_insights"]
  description = "Health Insights naming outputs."
}

output "hosting_environment" {
  value       = local.resources["hosting_environment"]
  description = "Hosting Environment naming outputs."
}

output "image_template" {
  value       = local.resources["image_template"]
  description = "Image Template naming outputs."
}

output "immersive_reader" {
  value       = local.resources["immersive_reader"]
  description = "Immersive Reader naming outputs."
}

output "integration_account" {
  value       = local.resources["integration_account"]
  description = "Integration Account naming outputs."
}

output "iot_hub" {
  value       = local.resources["iot_hub"]
  description = "Iot Hub naming outputs."
}

output "ip_group" {
  value       = local.resources["ip_group"]
  description = "Ip Group naming outputs."
}

output "key_vault" {
  value       = local.resources["key_vault"]
  description = "Key Vault naming outputs."
}

output "key_vault_managed_hsm" {
  value       = local.resources["key_vault_managed_hsm"]
  description = "Key Vault Managed Hsm naming outputs."
}

output "language_service" {
  value       = local.resources["language_service"]
  description = "Language Service naming outputs."
}

output "load_balancer" {
  value       = local.resources["load_balancer"]
  description = "Load Balancer naming outputs."
}

output "load_balancer_external" {
  value       = local.resources["load_balancer_external"]
  description = "Load Balancer External naming outputs."
}

output "load_balancer_internal" {
  value       = local.resources["load_balancer_internal"]
  description = "Load Balancer Internal naming outputs."
}

output "load_balancer_rule" {
  value       = local.resources["load_balancer_rule"]
  description = "Load Balancer Rule naming outputs."
}

output "local_network_gateway" {
  value       = local.resources["local_network_gateway"]
  description = "Local Network Gateway naming outputs."
}

output "log_analytics_query_packs" {
  value       = local.resources["log_analytics_query_packs"]
  description = "Log Analytics Query Packs naming outputs."
}

output "log_analytics_workspace" {
  value       = local.resources["log_analytics_workspace"]
  description = "Log Analytics Workspace naming outputs."
}

output "logic_app" {
  value       = local.resources["logic_app"]
  description = "Logic App naming outputs."
}

output "managed_devops_pools" {
  value       = local.resources["managed_devops_pools"]
  description = "Managed Devops Pools naming outputs."
}

output "managed_disk" {
  value       = local.resources["managed_disk"]
  description = "Managed Disk naming outputs."
}

output "managed_identity" {
  value       = local.resources["managed_identity"]
  description = "Managed Identity naming outputs."
}

output "management_group" {
  value       = local.resources["management_group"]
  description = "Management Group naming outputs."
}

output "maps_account" {
  value       = local.resources["maps_account"]
  description = "Maps Account naming outputs."
}

output "microsoft_purview_instance" {
  value       = local.resources["microsoft_purview_instance"]
  description = "Microsoft Purview Instance naming outputs."
}

output "mysql_database" {
  value       = local.resources["mysql_database"]
  description = "Mysql Database naming outputs."
}

output "nat_gateway" {
  value       = local.resources["nat_gateway"]
  description = "Nat Gateway naming outputs."
}

output "network_interface" {
  value       = local.resources["network_interface"]
  description = "Network Interface naming outputs."
}

output "network_security_group" {
  value       = local.resources["network_security_group"]
  description = "Network Security Group naming outputs."
}

output "network_security_group_security_rules" {
  value       = local.resources["network_security_group_security_rules"]
  description = "Network Security Group Security Rules naming outputs."
}

output "network_security_perimeter" {
  value       = local.resources["network_security_perimeter"]
  description = "Network Security Perimeter naming outputs."
}

output "network_watcher" {
  value       = local.resources["network_watcher"]
  description = "Network Watcher naming outputs."
}

output "notification_hubs" {
  value       = local.resources["notification_hubs"]
  description = "Notification Hubs naming outputs."
}

output "notification_hubs_namespace" {
  value       = local.resources["notification_hubs_namespace"]
  description = "Notification Hubs Namespace naming outputs."
}

output "postgresql_flexible_server" {
  value       = local.resources["postgresql_flexible_server"]
  description = "Postgresql Flexible Server naming outputs."
}

output "power_bi_embedded" {
  value       = local.resources["power_bi_embedded"]
  description = "Power Bi Embedded naming outputs."
}

output "private_endpoint" {
  value       = local.resources["private_endpoint"]
  description = "Private Endpoint naming outputs."
}

output "private_link" {
  value       = local.resources["private_link"]
  description = "Private Link naming outputs."
}

output "provisioning_services" {
  value       = local.resources["provisioning_services"]
  description = "Provisioning Services naming outputs."
}

output "provisioning_services_certificate" {
  value       = local.resources["provisioning_services_certificate"]
  description = "Provisioning Services Certificate naming outputs."
}

output "proximity_placement_group" {
  value       = local.resources["proximity_placement_group"]
  description = "Proximity Placement Group naming outputs."
}

output "public_ip_address" {
  value       = local.resources["public_ip_address"]
  description = "Public Ip Address naming outputs."
}

output "public_ip_address_prefix" {
  value       = local.resources["public_ip_address_prefix"]
  description = "Public Ip Address Prefix naming outputs."
}

output "recovery_services_vault" {
  value       = local.resources["recovery_services_vault"]
  description = "Recovery Services Vault naming outputs."
}

output "resource_group" {
  value       = local.resources["resource_group"]
  description = "Resource Group naming outputs."
}

output "restore_point_collection" {
  value       = local.resources["restore_point_collection"]
  description = "Restore Point Collection naming outputs."
}

output "route_filter" {
  value       = local.resources["route_filter"]
  description = "Route Filter naming outputs."
}

output "route_server" {
  value       = local.resources["route_server"]
  description = "Route Server naming outputs."
}

output "route_table" {
  value       = local.resources["route_table"]
  description = "Route Table naming outputs."
}

output "service_bus_namespace" {
  value       = local.resources["service_bus_namespace"]
  description = "Service Bus Namespace naming outputs."
}

output "service_bus_queue" {
  value       = local.resources["service_bus_queue"]
  description = "Service Bus Queue naming outputs."
}

output "service_bus_topic" {
  value       = local.resources["service_bus_topic"]
  description = "Service Bus Topic naming outputs."
}

output "service_bus_topic_subscription" {
  value       = local.resources["service_bus_topic_subscription"]
  description = "Service Bus Topic Subscription naming outputs."
}

output "service_endpoint_policy" {
  value       = local.resources["service_endpoint_policy"]
  description = "Service Endpoint Policy naming outputs."
}

output "service_fabric_cluster" {
  value       = local.resources["service_fabric_cluster"]
  description = "Service Fabric Cluster naming outputs."
}

output "service_fabric_managed_cluster" {
  value       = local.resources["service_fabric_managed_cluster"]
  description = "Service Fabric Managed Cluster naming outputs."
}

output "signalr" {
  value       = local.resources["signalr"]
  description = "Signalr naming outputs."
}

output "snapshot" {
  value       = local.resources["snapshot"]
  description = "Snapshot naming outputs."
}

output "speech_service" {
  value       = local.resources["speech_service"]
  description = "Speech Service naming outputs."
}

output "sql_managed_instance" {
  value       = local.resources["sql_managed_instance"]
  description = "Sql Managed Instance naming outputs."
}

output "ssh_key" {
  value       = local.resources["ssh_key"]
  description = "Ssh Key naming outputs."
}

output "static_web_app" {
  value       = local.resources["static_web_app"]
  description = "Static Web App naming outputs."
}

output "storage_account" {
  value       = local.resources["storage_account"]
  description = "Storage Account naming outputs."
}

output "storage_sync_service_name" {
  value       = local.resources["storage_sync_service_name"]
  description = "Storage Sync Service Name naming outputs."
}

output "template_specs_name" {
  value       = local.resources["template_specs_name"]
  description = "Template Specs Name naming outputs."
}

output "time_series_insights_environment" {
  value       = local.resources["time_series_insights_environment"]
  description = "Time Series Insights Environment naming outputs."
}

output "traffic_manager_profile" {
  value       = local.resources["traffic_manager_profile"]
  description = "Traffic Manager Profile naming outputs."
}

output "translator" {
  value       = local.resources["translator"]
  description = "Translator naming outputs."
}

output "user_defined_route" {
  value       = local.resources["user_defined_route"]
  description = "User Defined Route naming outputs."
}

output "virtual_desktop_application_group" {
  value       = local.resources["virtual_desktop_application_group"]
  description = "Virtual Desktop Application Group naming outputs."
}

output "virtual_desktop_host_pool" {
  value       = local.resources["virtual_desktop_host_pool"]
  description = "Virtual Desktop Host Pool naming outputs."
}

output "virtual_desktop_scaling_plan" {
  value       = local.resources["virtual_desktop_scaling_plan"]
  description = "Virtual Desktop Scaling Plan naming outputs."
}

output "virtual_desktop_workspace" {
  value       = local.resources["virtual_desktop_workspace"]
  description = "Virtual Desktop Workspace naming outputs."
}

output "virtual_machine" {
  value       = local.resources["virtual_machine"]
  description = "Virtual Machine naming outputs."
}

output "virtual_machine_maintenance_configuration" {
  value       = local.resources["virtual_machine_maintenance_configuration"]
  description = "Virtual Machine Maintenance Configuration naming outputs."
}

output "virtual_machine_scale_set" {
  value       = local.resources["virtual_machine_scale_set"]
  description = "Virtual Machine Scale Set naming outputs."
}

output "virtual_network" {
  value       = local.resources["virtual_network"]
  description = "Virtual Network naming outputs."
}

output "virtual_network_gateway" {
  value       = local.resources["virtual_network_gateway"]
  description = "Virtual Network Gateway naming outputs."
}

output "virtual_network_manager" {
  value       = local.resources["virtual_network_manager"]
  description = "Virtual Network Manager naming outputs."
}

output "virtual_network_peering" {
  value       = local.resources["virtual_network_peering"]
  description = "Virtual Network Peering naming outputs."
}

output "virtual_network_subnet" {
  value       = local.resources["virtual_network_subnet"]
  description = "Virtual Network Subnet naming outputs."
}

output "virtual_wan" {
  value       = local.resources["virtual_wan"]
  description = "Virtual Wan naming outputs."
}

output "virtual_wan_hub" {
  value       = local.resources["virtual_wan_hub"]
  description = "Virtual Wan Hub naming outputs."
}

output "vm_storage_account" {
  value       = local.resources["vm_storage_account"]
  description = "Vm Storage Account naming outputs."
}

output "vpn_connection" {
  value       = local.resources["vpn_connection"]
  description = "Vpn Connection naming outputs."
}

output "vpn_gateway" {
  value       = local.resources["vpn_gateway"]
  description = "Vpn Gateway naming outputs."
}

output "vpn_site" {
  value       = local.resources["vpn_site"]
  description = "Vpn Site naming outputs."
}

output "web_app" {
  value       = local.resources["web_app"]
  description = "Web App naming outputs."
}

output "web_application_firewall_policy" {
  value       = local.resources["web_application_firewall_policy"]
  description = "Web Application Firewall Policy naming outputs."
}

output "web_application_firewall_policy_rule_group" {
  value       = local.resources["web_application_firewall_policy_rule_group"]
  description = "Web Application Firewall Policy Rule Group naming outputs."
}

output "webpubsub" {
  value       = local.resources["webpubsub"]
  description = "Webpubsub naming outputs."
}
