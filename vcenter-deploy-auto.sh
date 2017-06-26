#!/bin/bash

function VC_Deploy
{
cp -p /mnt/iso/vcsa-cli-installer/templates/install/embedded_vCSA_on_ESXi.json /home/tse-admin/Deploy-Templates/embedded_vCSA_on_ESXi.json
cd /home/tse-admin/Deploy-Templates/
touch embedded_vCSA_on_ESXi-complete.json
cat << EOF > /home/tse-admin/Deploy-Templates/embedded_vCSA_on_ESXi-complete.json
{


    "__version": "1.1",
    "__comments": "Sample template to deploy a vCenter Server with an embedded Platform Services Controller to an ESXi host.",
    "target.vcsa": {
        "appliance": {
            "deployment.network": "$VM_network",
            "deployment.option": "small",
            "name": "VC6-Embedded",
            "thin.disk.mode": true
        },
        "esx": {
            "hostname": "$esx_host",
            "username": "root",
            "password": "$root_password",
            "datastore": "$storage"
        },
        "network": {
            "hostname": "vcsa6.vcloud.local",
            "dns.servers": [
                "192.168.1.2"
            ],
            "gateway": "192.168.1.1",
            "ip": "192.168.1.10",
            "ip.family": "ipv4",
            "mode": "static",
            "prefix": "24"
        },
        "os": {
            "password": "VMware123!",
            "ssh.enable": true
        },
        "sso": {
            "password": "VMware123!",
            "domain-name": "vsphere.local",
            "site-name": "Site-A"
        }
    }
}
EOF
}

function Input_Parameters
{
        read -p "Enter the root password for this host: " root_password
        read -p "Enter the datastore name where this vCenter should reside: " storage
        read -p "Enter the VM Port Group name: " VM_network
}

        cd /home/tse-admin/Deploy-Scripts/
        printf "\nEnter the below required parameters\n\n"
        Input_Parameters
        VC_Deploy
        echo "Deployment In progress"
        echo
        cd /mnt/iso/vcsa-cli-installer/lin64
        ./vcsa-deploy install --no-esx-ssl-verify --accept-eula  /home/tse-admin/Deploy-Templates/embedded_vCSA_on_ESXi-complete.json
        rm -f /home/tse-admin/Deploy-Templates/embedded_vCSA_on_ESXi-complete.json
        rm -f /home/tse-admin/Deploy-Templates/embedded_vCSA_on_ESXi.json
