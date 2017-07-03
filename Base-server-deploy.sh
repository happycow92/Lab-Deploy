G="\033[32m"
N="\033[0m"
R="\033[31m"
Y="\033[33m"
clear
read -p "Enter the name of the datastore where this template was copied to: " datastore

cd /vmfs/volumes/$datastore/Jump-VM
printf "\n${Y}Deploying Jump Server${N}"
printf "\n${Y}Renaming the vmtx file${N}\n"
cd /vmfs/volumes/$datastore/Jump-VM/
mv Jump-VM.vmtx Jump-VM.vmx

printf "\n${G}Registering the VM${N}\n"
vim-cmd solo/registervm /vmfs/volumes/$datastore/Jump-VM/Jump-VM.vmx | tee -a vid.txt

printf "\n${Y}Powering On the Jump server${N}. "
VID=$(cat vid.txt)
vim-cmd vmsvc/power.on $VID
echo "Jump Server is $(vim-cmd vmsvc/power.getstate $VID | tail -n+2)"
rm vid.txt


# Deploying AD

cd /vmfs/volumes/$datastore/AD-VM
printf "\n${Y}Deploying AD Server${N}"
printf "\n${Y}Renaming the vmtx file${N}\n"
mv AD-VM.vmtx AD-VM.vmx

printf "\n${G}Registering the VM${N}\n"
vim-cmd solo/registervm /vmfs/volumes/$datastore/AD-VM/AD-VM.vmx | tee -a vid.txt

printf "\n${Y}Powering On the AD Server${N}. "
VID=$(cat vid.txt)
vim-cmd vmsvc/power.on $VID
echo "AD Server is $(vim-cmd vmsvc/power.getstate $VID | tail -n+2)"
rm vid.txt

# Final Messages

sleep 5s

printf "\n${G}Configure the IP of the Jump and the AD server as per the deployment guide${N}\n"
printf "${Y}Now exiting the Server deployment script and taking you back to RHEL box.....Thank you!${N}\n\n" && exit
