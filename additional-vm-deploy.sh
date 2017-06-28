#!/bin/sh

Create_VM ()
{
read -p "Enter the VM name: " VM_name
read -p "Enter the path of the datastore. /vmfs/volumes/<storage-name>/: " datastore_name
cd /vmfs/volumes/$datastore_name
mkdir $VM_name && cd $VM_name && touch $VM_name.vmx

read -p "Enter the Hardware version for the VM: " HW_version
read -p "Enter the Memory required for the VM: " Memory
read -p "Enter the network type, e1000 / VMXNET3: " Net_type
read -p "Enter the VM Port group name: " Port_group

# VMX File Entries
cat << EOF > $VM_name.vmx

.encoding = "UTF-8"
config.version = "8"
virtualHW.version = "$HW_version"
nvram = "$VM_name.nvram"
pciBridge0.present = "TRUE"
svga.present = "TRUE"
pciBridge4.present = "TRUE"
pciBridge4.virtualDev = "pcieRootPort"
pciBridge4.functions = "8"
pciBridge5.present = "TRUE"
pciBridge5.virtualDev = "pcieRootPort"
pciBridge5.functions = "8"
pciBridge6.present = "TRUE"
pciBridge6.virtualDev = "pcieRootPort"
pciBridge6.functions = "8"
pciBridge7.present = "TRUE"
pciBridge7.virtualDev = "pcieRootPort"
pciBridge7.functions = "8"
vmci0.present = "TRUE"
hpet0.present = "TRUE"
memSize = "$Memory"
scsi0.virtualDev = "lsisas1068"
scsi0.present = "TRUE"
ide1:0.startConnected = "FALSE"
ide1:0.deviceType = "cdrom-raw"
ide1:0.clientDevice = "TRUE"
ide1:0.fileName = "emptyBackingString"
ide1:0.present = "TRUE"
floppy0.startConnected = "FALSE"
floppy0.clientDevice = "TRUE"
floppy0.fileName = "vmware-null-remote-floppy"
ethernet0.virtualDev = "$Net_type"
ethernet0.networkName = "$Port_group"
ethernet0.checkMACAddress = "false"
ethernet0.addressType = "static"
ethernet0.Address = "$final_mac"
ethernet0.present = "TRUE"
scsi0:0.deviceType = "scsi-hardDisk"
scsi0:0.fileName = "$VM_name.vmdk"
scsi0:0.present = "TRUE"
displayName = "$VM_name"
guestOS = "windows8srv-64"
disk.EnableUUID = "TRUE"
toolScripts.afterPowerOn = "TRUE"
toolScripts.afterResume = "TRUE"
toolScripts.beforeSuspend = "TRUE"
toolScripts.beforePowerOff = "TRUE"
uuid.bios = "$uuid"
vc.uuid = "$vcid"
ctkEnabled = "TRUE"
scsi0:0.ctkEnabled = "TRUE"
EOF
}


        Create_VMDK ()
        {
        read -p "Enter disk format. thin / zeroedthick / eagerzeroedthick: " format
        read -p "Enter size: " size

        vmkfstools -c "$size"G -d $format $VM_name.vmdk
        }

        Register_VM ()
        {
        echo -e "\nRegistering VM....."
        vim-cmd solo/registervm /vmfs/volumes/$datastore_name/$VM_name/$VM_name.vmx | tee -a vid.txt
        }

        MAC_address ()
        {

        mac=$(awk -v min=1000 -v max=9000 'BEGIN{srand(); print int(min+rand()*(max-min+1))}' | sed -e 's/.\{2\}/&:/g;s/.$//')
        final_mac=00:50:56:00:$mac

        }

        UUID_generate ()
        {
        uuid_postfix="1a c2 4e fe 1a 8c d2-db 90 02 81 ce d8 31 15"
        vcid_postfix="1a c9 91 4b 4a b9 93-79 23 12 1f b2 c5 37 f8"

        uuid_prefix=$(awk -v min=10 -v max=99 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
        vcid_prefix=$(awk -v min=10 -v max=99 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')

        uuid="$uuid_prefix $uuid_postfix"
        vcid="$vcid_prefix $vcid_postfix"


        }

        Power_On ()
        {
        VID=$(cat vid.txt)
        vim-cmd vmsvc/power.on $VID
        echo "VM $VM_name is $(vim-cmd vmsvc/power.getstate $VID | tail -n+2)"
        rm vid.txt
        }

        echo
        read -p "How many VMs you want to deploy: " how_many
        current=1

        while [ $current -le $how_many ]
        do
                UUID_generate

                MAC_address

                Create_VM

                Create_VMDK

                Register_VM

                Power_On
                current=$(expr $current + 1)

        done && exit
