#!/bin/bash

function VC_Node
{
cp -p /mnt/iso/vcsa-cli-installer/templates/install/VC_on_ESXi.json /home/tse-admin/Deploy-Templates/VC_on_ESXi.json
cd /home/tse-admin/Deploy-Templates/
touch VC_on_ESXi-complete.json
cat << EOF > /home/tse-admin/Deploy-Templates/VC_on_ESXi-complete.json
{
    "__version": "1.1",
    "__comments": "Sample template to deploy a vCenter Server to an ESXi host.",
    "target.vcsa": {
        "appliance": {
            "deployment.network": "$VM_network",
            "deployment.option": "management-small",
            "name": "$vc_name",
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
            "platform.service.controller": "$psc_hostname",
            "ssh.enable": true
        },
        "sso": {
            "password": "$sso_password",
            "domain-name": "$domain_name",
            "site-name": "$site_name"
        }
    }
}
EOF
}

function Input_Parameters
{
        read -p "Enter A Name for the VC Node Appliance: " vc_name
        read -p "Enter the host IP where this VC Node should be deployed: " esx_host
        read -p "Enter the root password for this host: " root_password
        read -p "Enter the datastore name where this vCenter should reside: " storage
                read -p "Enter the VM Port Group name: " VM_network
        read -p "Enter the FQDN for the VC node: " host_name
        read -p "Enter the DNS server IP: " dns
        read -p "Enter the Management IP for VC node Appliance: " mgmt_ip
        read -p "Enter the Subnet Prefix /24 format: " subnet_prefix
        read -p "Enter the gateway address for VC Node: " gateway
        read -p "Enter the Password for the root user of VC Node: " os_password
                read -p "Enter the FQDN of the PSC node to which this VC must be configuted: " psc_hostname
        read -p "Enter the SSO domain name that was configured for your PSC: " domain_name
        read -p "Enter the password for this SSO domain user: " sso_password
                read -p "Enter the configured SSO Site-Name: " site_name
}


        cd /home/tse-admin/Deploy-Scripts
        Input_Parameters
        VC_Node
        echo -e "\nVC Deployment In progress"
        echo
        cd /mnt/iso/vcsa-cli-installer/lin64
        ./vcsa-deploy install --no-esx-ssl-verify --accept-eula  /home/tse-admin/Deploy-Templates/VC_on_ESXi-complete.json
        rm -f /home/tse-admin/Deploy-Templates/VC_on_ESXi-complete.json
        rm -f /home/tse-admin/Deploy-Templates/VC_on_ESXi.json
