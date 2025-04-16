#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common &&
curl -fssl https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
sudo apt-get update -y &&
sudo sudo apt-get install docker-ce docker-ce-cli containerd.io git -y &&
sudo usermod -aG docker ubuntu
sudo apt-get update -y

# Install terraform
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update -y

# TPL Script for Adding Application and Fixing VM Extension Issue

# Check Network Access
echo "Checking network access..."
sudo vi /lib/systemd/system/walinuxagent.service <<EOF
[Service]
Environment="http_proxy=http://proxy.example.com:80/"
Environment="https_proxy=http://proxy.example.com:80/"
Environment="no_proxy=169.254.169.254"
EOF

# Reload systemd and restart waagent service
sudo systemctl daemon-reload
sudo systemctl restart walinuxagent

# Install Required Packages
echo "Installing required packages..."
sudo apt-get update
sudo apt-get install -y aadlogin

# Retry Installation
echo "Retrying installation..."
sudo /var/lib/waagent/Microsoft.Azure.ActiveDirectory.LinuxSSH.AADLoginForLinux-1.0.1588.3/./installer.sh install

# Enable Managed Identity
echo "Enabling managed identity..."
az vm identity assign --resource-group multi-agent-ecosystem-rg --name multi-agent-vm

# # Terraform Configuration for VM Extension
echo "Configuring Terraform for VM extension..."
cat <<EOF > main.tf
resource "azurerm_virtual_machine_extension" "AADLoginForLinux" {
  name                          = "AADLoginForLinux"
  location                      = azurerm_virtual_machine.vm-linux.location
  resource_group_name           = azurerm_virtual_machine.vm-linux.resource_group_name
  virtual_machine_name          = azurerm_virtual_machine.vm-linux.name
  publisher                     = "Microsoft.Azure.ActiveDirectory"
  type                          = "AADLoginForLinux"
  type_handler_version          = "1.0"
  auto_upgrade_minor_version    = true
}
EOF

# Apply Terraform Configuration
echo "Applying Terraform configuration..."
terraform init
terraform apply -auto-approve

echo "Script execution completed."



# Install Azure CLI and Azure Developer CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
curl -fsSL https://aka.ms/install-azd.sh | bash
sudo apt-get update -y

# Install miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh 
bash chmod +x Miniconda3-latest-Linux-x86_64.sh
bash ./Miniconda3-latest-Linux-x86_64.sh
conda init
conda update conda -y

# Install Poetry
sudo apt-get update -y
curl -sSL https://install.python-poetry.org | python3 -
bash sudo apt install python3-poetry
bash poetry self add poetry-plugin-export



