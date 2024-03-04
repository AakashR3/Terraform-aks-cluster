provider "azurerm" {
  features {}
}

resource "azurerm_user_assigned_identity" "user_mi" {
  resource_group_name = var.rg_name
  location            = var.location
  tags                = var.tags

  name = "mi-${var.cluster_name}"
}

data "azurerm_resource_group" "example" {
  name     = "Aakash-RG"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "aks-${var.cluster_name}"
  location            = "East US"
  resource_group_name = "Aakash-RG"

  kubernetes_version = var.kubernetes_version
  sku_tier            = "Free"
  local_account_disabled = var.local_account_disabled
  #automatic_channel_upgrade = var.automatic_channel_upgrade
  dns_prefix                = "aks${var.cluster_name}"

  default_node_pool {
    name                  = var.default_node_pool.name
    node_count            = var.default_node_pool.node_count
    vm_size               = var.default_node_pool.vm_size
    type                  = var.default_node_pool.vm_type
    os_disk_size_gb       = var.default_node_pool.os_disk_size_gb
    vnet_subnet_id        = var.default_node_pool.subnet_id
    zones                 = var.enable_availability_zones ? ["3"] : []
    enable_auto_scaling   = var.default_node_pool.enable_autoscaling
    max_count             = var.default_node_pool.enable_autoscaling ? var.default_node_pool.autoscaling_max_nodes : null
    min_count             = var.default_node_pool.enable_autoscaling ? var.default_node_pool.autoscaling_min_nodes : null
    max_pods              = var.default_node_pool.max_pods
    enable_node_public_ip = false
    node_labels           = var.default_node_pool.kube_node_labels
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_mi.id]
  }

  network_profile {
    network_plugin     = lower(var.network_plugin)
    network_policy     = lower(var.network_plugin) == "azure" ? "azure" : "calico"
    dns_service_ip     = var.dns_service_ip != "" ? var.dns_service_ip : null
    pod_cidr           = lower(var.network_plugin) == "kubenet" ? var.pod_cidr : null
    service_cidr       = var.service_cidr != "" ? var.service_cidr : null
}
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_role_based_access_control && var.rbac_aad_managed ? ["rbac"] : []

    content {
      managed                = true
      azure_rbac_enabled     = true
      admin_group_object_ids = concat(var.rbac_aad_admin_group_object_ids)
    }
  }

  tags = var.tags
}
