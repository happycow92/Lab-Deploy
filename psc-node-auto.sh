#!/bin/bash

function PSC_Node
{
cp -p /mnt/iso/vcsa-cli-installer/templates/install/PSC_on_ESXi.json /home/tse-admin/Deploy-Templates/PSC_on_ESXi.json
cd /home/tse-admin/Deploy-Templates/
touch PSC_on_ESXi-complete.json
cat << EOF > /home/tse-admin/Deploy-Templates/PSC_on_ESXi-complete.json
{
    "__version": "1.1",
    "__comments": "Sample template to deploy a Platform Services Controller to an ESXi host.",
    "target.vcsa": {
        "appliance": {
            "deployment.network": "$VM_network",
            "deployment.option": "infrastructure",
            "name": "$psc_name",
            "thin.disk.mode": true
        },
        "esx": {
            "hostname": "$esx_host",
            "username": "root",
            "password": "$root_password",
            "datastore": "$storage"
        },
        "network": {
            "hostname": "$host_name",
            "dns.servers": "$dns",
            "gateway": "$gateway",
            "ip": "$mgmt_ip",
            "ip.family": "ipv4",
            "mode": "static",
            "prefix": "$subnet_prefix"
        },
        "os": {
            "password": "$os_password",
            "ssh.enable": true
        },
        "sso": {
            "password": "$sso_password",
            "domain-name": "$domain_name",
            "site-name": "$Site_Name"
        }
    }
}
EOF
}

function Input_Parameters
{
        read -p "Enter A Name for the PSC Appliance: " psc_name
        read -p "Enter the host IP where this PSC should be deployed: " esx_host
        read -p "Enter the root password for this host: " root_password
        read -p "Enter the datastore name where this vCenter should reside: " storage
        read -p "Enter the SSO Site-Name: " Site_Name
        read -p "Enter the SSO domain name that you want to set: " domain_name
        read -p "Enter the password for this SSO domain user: " sso_password
        read -p "Enter the VM Port Group name: " VM_network
        read -p "Enter the FQDN for this PSC: " host_name
        read -p "Enter the DNS server IP: " dns
        read -p "Enter the Management IP for PSC Appliance: " mgmt_ip
        read -p "Enter the Subnet Prefix /24 format: " subnet_prefix
        read -p "Enter the gateway address for PSC: " gateway
        read -p "Enter the Password for the root user of PSC: " os_password
}

        cd /home/tse-admin/Deploy-Scripts/
        Input_Parameters
        PSC_Node
        echo "PSC Deployment In progress"
        echo
        cd /mnt/iso/vcsa-cli-installer/lin64
        ./vcsa-deploy install --no-esx-ssl-verify --accept-eula  /home/tse-admin/Deploy-Templates/PSC_on_ESXi-complete.json
        rm -f /home/tse-admin/Deploy-Templates/PSC_on_ESXi-complete.json
        rm -f /home/tse-admin/Deploy-Templates/PSC_on_ESXi.json
