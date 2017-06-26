template_folder_jump=Jump-Cloud
template_folder_ad=AD-vCloud
read -p "Enter the name of the datastore where this template was copied to: " datastore

# Deploying Jump
cd /vmfs/volumes/$datastore/$template_folder_jump/

printf "\nDeploying Jump Server"
printf "\nRenaming the vmtx file\n"
mv Jump-Cloud.vmtx Jump-Cloud.vmx

printf "\nRegistering the VM\n"
vim-cmd solo/registervm /vmfs/volumes/$datastore/$template_folder_jump/Jump-Cloud.vmx | tee -a vid.txt

printf "\nPowering On the Jump server\n"
VID=$(cat vid.txt)
vim-cmd vmsvc/power.on $VID
echo "Jump Server is $(vim-cmd vmsvc/power.getstate $VID | tail -n+2)"
rm vid.txt


# Deploying AD
cd /vmfs/volumes/$datastore/$template_folder_ad/

printf "\nDeploying AD Server"
printf "\Renaming the vmtx file\n"
mv AD-vCloud.vmtx AD-vCloud.vmx

printf "\nRegistering the VM\n"
vim-cmd solo/registervm /vmfs/volumes/$datastore/$template_folder_ad/AD-vCloud.vmx | tee -a vid.txt

printf "\nPowering On the AD Server\n"
VID=$(cat vid.txt)
vim-cmd vmsvc/power.on $VID
echo "AD Server is $(vim-cmd vmsvc/power.getstate $VID | tail -n+2)"
rm vid.txt

# Final Messages

sleep 5s

echo -e "\nConfigure the IP of the Jump and the AD server as per the deployment guide\n"
echo -e "Now exiting the Server deployment script and taking you back to RHEL box.....Thank you!\n\n" && exit
