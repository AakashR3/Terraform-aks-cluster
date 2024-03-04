locals {
  np_subnet_ids = flatten([
    for np in var.node_pools : [
      np.subnet_id
    ]
  ])
  node_subnet_ids = distinct(concat([var.default_node_pool.subnet_id], local.np_subnet_ids))

  subnet_info = { for sn in local.node_subnet_ids : sn => {
    name      = split("/", sn)[10]
    rg_name   = split("/", sn)[4]
    vnet_name = split("/", sn)[8]
    }
  }
}

