# Dev BOX  

This terraform template spins up a linux vm in your tenant within a VNET with an SSH capability for connecting. The template will copy your key to the linux box so you don't have to log in with a user and password.  

## Update the Host File  

Depending upon whether you are using linux, mac, or windows you need to update the terraform.tfvars with your ssh host config file. For windows change the user profile to your path

## Use Remote Host  

You can now use Remote Host from VS Code to connect to your Linux VM.