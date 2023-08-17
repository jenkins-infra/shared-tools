####################################################################################
## Resources for the Controller VM
####################################################################################
resource "azurerm_resource_group" "controller" {
  name     = var.controller_resourcegroup_name == "" ? "${local.service_stripped_name}-controller" : var.controller_resourcegroup_name
  location = var.location
  tags     = var.default_tags
}
resource "azurerm_public_ip" "controller" {
  count               = var.is_public ? 1 : 0
  name                = local.controller_fqdn
  location            = azurerm_resource_group.controller.location
  resource_group_name = azurerm_resource_group.controller.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.default_tags
}
resource "azurerm_management_lock" "controller_publicip" {
  count      = var.is_public ? 1 : 0
  name       = "${local.service_stripped_name}-controller-publicip"
  scope      = azurerm_public_ip.controller[0].id
  lock_level = "CanNotDelete"
  notes      = "Locked because this is a sensitive resource that should not be removed"
}
resource "azurerm_dns_a_record" "controller" {
  count               = var.is_public ? 1 : 0
  name                = trimsuffix(trimsuffix(local.controller_fqdn, var.dns_zone), ".")
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_resourcegroup_name
  ttl                 = 60
  records             = [azurerm_public_ip.controller[0].ip_address]
  tags                = var.default_tags
}
resource "azurerm_dns_a_record" "private_controller" {
  count               = var.is_public ? 1 : 0
  name                = "private.${azurerm_dns_a_record.controller[0].name}"
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_resourcegroup_name
  ttl                 = 60
  records             = [azurerm_network_interface.controller.private_ip_address]
  tags                = var.default_tags
}
resource "azurerm_network_interface" "controller" {
  name                = local.controller_fqdn
  location            = azurerm_resource_group.controller.location
  resource_group_name = azurerm_resource_group.controller.name
  tags                = var.default_tags

  ip_configuration {
    name                          = var.is_public ? "external" : "internal"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.is_public ? azurerm_public_ip.controller[0].id : null
    subnet_id                     = var.controller_subnet_id
  }
}
resource "azurerm_managed_disk" "controller_data" {
  name                 = var.controller_datadisk_name == "" ? "${local.controller_fqdn}-data" : var.controller_datadisk_name
  location             = azurerm_resource_group.controller.location
  resource_group_name  = azurerm_resource_group.controller.name
  storage_account_type = var.controller_data_disk_type
  create_option        = "Empty"
  disk_size_gb         = var.controller_data_disk_size_gb

  tags = var.default_tags
}
resource "azurerm_linux_virtual_machine" "controller" {
  name                            = local.controller_fqdn
  resource_group_name             = azurerm_resource_group.controller.name
  location                        = azurerm_resource_group.controller.location
  tags                            = var.default_tags
  size                            = var.controller_vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.controller.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_publickey
  }

  user_data     = base64encode(templatefile("${path.root}/.shared-tools/terraform/cloudinit.tftpl", { hostname = local.controller_fqdn }))
  computer_name = local.controller_fqdn

  # Encrypt all disks (ephemeral, temp dirs and data volumes) - https://learn.microsoft.com/en-us/azure/virtual-machines/disks-enable-host-based-encryption-portal?tabs=azure-powershell
  encryption_at_host_enabled = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.controller_os_disk_type
    disk_size_gb         = var.controller_os_disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-minimal-jammy"
    sku       = "minimal-22_04-lts-gen2"
    version   = "latest"
  }
}
resource "azurerm_virtual_machine_data_disk_attachment" "controller_data" {
  managed_disk_id    = azurerm_managed_disk.controller_data.id
  virtual_machine_id = azurerm_linux_virtual_machine.controller.id
  lun                = "10"
  caching            = "ReadWrite"
}
