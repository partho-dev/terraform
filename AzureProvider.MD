## Work with azure as a target cloud provider 🌧️
1. Install the Azure CLI
- https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-macos
2. type `az login` on the cli which will authenticate with the azure portal
3. Install `Terraform`
4. Find the Azure provider - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

### What are the list of resources we would need for Azure 🔥
- ✅ create the resource group
- ✅ create virtual network 
- ✅ create subnet inside that vnet (azurerm_subnet)
- ✅ security Group (azurerm_network_security_group)
- ✅ security rule to be applied to above security group (azurerm_network_security_rule)
- ✅ associate the security rule to above sg using (azurerm_subnet_network_security_group_association)
- ✅ Create public IP (azurerm_public_ip)
- ✅ network interface (azurerm_network_interface)
- ✅ create a virtual machine & associate the above NIC with this (azurerm_linux_virtual_machine)


## Project - setting up one VM in a private subnet and another in a public subnet using Terraform
1. Create the Resource Group:
```
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}
```

2. Create the Virtual Network:
```
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
```

3. Create subnet
- Public
```
resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}
```
- private 
```
resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}
```

4. Create Network Security Group (NSG):
```
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
```

5. Create Security Rules
```
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow_ssh"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.example.name
}
```

6. Associate NSG with Subnets
- public subnet association
```
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.example.id
}
```

- private subnet association
```
resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.example.id
}
```

7. Create public IP 
```
resource "azurerm_public_ip" "example" {
  name                = "example-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}
```

8. Create two NIC
- Public NIC
```
resource "azurerm_network_interface" "public" {
  name                = "example-public-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}
```

- Private NIC
```
resource "azurerm_network_interface" "private" {
  name                = "example-private-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }
}
```

9. Create VM
- Public VM
```
resource "azurerm_linux_virtual_machine" "public" {
  name                = "example-public-vm"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  network_interface_ids = [
    azurerm_network_interface.public.id,
  ]
  size = "Standard_DS1_v2"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_username = "adminuser"
  admin_password = "Password1234!"

  disable_password_authentication = false
}
```

- Private VM
```
resource "azurerm_linux_virtual_machine" "private" {
  name                = "example-private-vm"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  network_interface_ids = [
    azurerm_network_interface.private.id,
  ]
  size = "Standard_DS1_v2"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_username = "adminuser"
  admin_password = "Password1234!"

  disable_password_authentication = false
}
```

## Make the same code more optimised and dynamic using loop and for-each
