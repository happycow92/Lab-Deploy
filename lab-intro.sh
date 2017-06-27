#!/bin/bash

clear

G="\033[32m"
N="\033[0m"
R="\033[31m"
Y="\033[33m"

printf "${R}-----------------------------------------------------${N}\n"
echo "Welcome to the lab deploy script v1.0.0"
echo "This Script is written by Suhas G, gsuhas@vmware.com"
printf "${R}-----------------------------------------------------${N}"
echo
echo "The script does the following"
printf "${G}1. Deploys a Jump Server${N}\n"
printf "${G}2. Deploys an Active Directory Server${N}\n"
printf "${G}3. Deploys vCenter Appliance (Embedded or External)${N}\n"
printf "${G}4. Deploys Few VMs without Operating Systems${N}\n"

echo
printf "\n${R}The script requires an ESXI with external network access${N}\n"
printf "${R}The RHEL server, 10.x.x.x with tse-admin as the login and XXXXXXX! as the password\n${N}"
echo "For bugs or feature enhancements email gsuhas@vmware.com"
echo

printf "${Y}Performing Network tests${N}\n"
read -p "Enter your ESXi's external IP: " esx_host
export esx_host

if ping -q -c 1 -W 1 $esx_host &> /dev/null;
then
        printf "${G}\nNetwork Good. Proceeding further\n${N}"
else
        printf  "${R}\nUnable to connect. Exiting script\n\n${N}"
        exit 1
fi

read -p "Press Y to read about deployment guide and IP Addressing. Press N to skip: " option

case $option in
        y|Y)
                clear
                cat /home/tse-admin/Deploy-Scripts/Deployment-guide.txt
        ;;
        n|N)
                printf "\n${Y}Continuing to deployment....${N}"
        ;;
        ?)
                printf "${R}Invalid Option. Exiting script\n\n${N}"
                exit 1;
        ;;
esac

printf "\n${Y}Hi There, we will start deploying of Jump Server and an Active Directory server now\n${N}"
read -p "Copying over files. Enter the datastore name of your ESXi server: " datastore_name

printf "\n${Y}Copying AD files. Enter ESXi password${N}\n"
scp -r /run/media/tse-admin/Lab-Files/Lab-Templates/AD-VM root@$esx_host:/vmfs/volumes/$datastore_name/

printf "\n${Y}Copying Jump Files. Enter ESXi password${N}\n"
scp -r /run/media/tse-admin/Lab-Files/Lab-Templates/Jump-VM root@$esx_host:/vmfs/volumes/$datastore_name/

printf "\n${Y}Copying Few scripts. Enter password again${N}\n"
scp -r /home/tse-admin/Deploy-Scripts/base-server-deploy.sh root@$esx_host:/vmfs/volumes/$datastore_name/

printf "\n\n${G}Copy Complete. SSH'ing again into the host\n${N}"
printf "${Y}Go to the /vmfs/volumes/$datastore_name/ and begin executing the base-server-deploy.sh${N}\n"
printf "${Y}Run or source the script as . base-server-deploy.sh${N}\n"
ssh root@$esx_host

echo

read -p "Do you want to proceed. Y/N: " choice

case $choice in
        y|Y)
                clear
                echo
                printf "\n${G}Taking into consideration that AD and Jump is configured. If not, configure the VM and then proceed${N}\n"
                printf "\n${Y}Proceeding with vCenter deployment${N}\n"
                read -p "Embedded PSC deployment or External? Embedded/External: " psc_choice

                case $psc_choice in
                        "embedded"|"Embedded")
                                echo
                                read -p "Would you like manual configuration or auto configuration of $psc_choice node: " config
                                if [ "$config" == "manual" ]
                                then
                                        printf "\n\n${Y}Deploying Embedded PSC in $config mode......${N}\n"
                                        ./vcenter-embedded-psc-deploy-manual.sh
                                else
                                        printf "\n\n${Y}Deploying Embedded PSC in $config mode......${N}\n"
                                        ./vcenter-embedded-psc-deploy-auto.sh
                                fi
                        ;;
                        "external"|"External")
                                echo
                                read -p "Would you like manual configuration or auto configuration of $psc_choice node: " config
                                if [ "$config" == "manual" ]
                                then
                                        printf "\n\n${Y}Deploying External PSC in $config mode......${N}\n"
                                        printf "${Y}Enter the PSC Details........${N}\n"
                                        ./psc-external-deploy-manual.sh

                                        printf "\n\n${Y}Deploying vCenter Node in $config mode......${N}\n"
                                        printf "${Y}Enter the vCenter Details........${N}\n"
                                        ./vc-external-deploy-manual.sh
                                else
                                        printf "\n\n${Y}Deploying External PSC in $config mode......${N}\n"
                                        printf "${Y}Enter the PSC Details........${N}\n"
                                        ./psc-external-deploy-auto.sh

                                        printf "\n\n${Y}Deploying vCenter Node in $config mode......${N}\n"
                                        printf "${Y}Enter the vCenter Details........${N}\n"
                                        ./vc-external-deploy-auto.sh
                                fi
                        ;;
                        ?)
                                printf "\n${R}Invalid Input. Exiting Script${N}\n\n"
                                exit 1
                        ;;
                esac
        ;;
        n|N)
                printf "${Y}Thank you. Exiting Script${N}\n\n"
        ;;
        ?)
                printf "${R}Invalid Input. Exiting Script${N}\n\n"
        ;;
esac

printf "${Y}And we are the last part. Do you want to deploy few dummy VMs?${N}"
read -p "Press Y to proceed and N to exit: " option

case $option in
        y|Y)
                printf "${Y}Deploying of VMs will begin. Copying script to ESXi storage. Provide ESX Password\n${N}"
                scp /home/tse-admin/Deploy-Scripts/additional-vm-deployment.sh root@esx_host:/vmfs/volumes/$datastore_name/
                echo -e "\nCopy done. SSH'ing to host. Go to /vmfs/volumes/$datastore_name/"
                printf " Run the script as . additional-vm-deployment.sh\n"
        ;;
        n|N)
                printf "\n${Y}Thank you for using the script. Suggestions always welcome${N}\n\n"
        ;;
        ?)
                printf "\n${R}Invalid option. Exiting script. ${N}\n\n"
                exit 1
        ;;
esac
