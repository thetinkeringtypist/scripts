#! Script to compress a VHD image after the unused
#  space has been defragged and/or zeroed out
#
#! Author: Bezeredi, Evan D.

$vms = $null

#! Check arguments
if ($args.length -eq 0) {
	echo "Usage: .\compact-vhd.ps1 vm-name1 vm-name2 ..."
	exit
}

#! Figure out which machines to compress
foreach ($arg in $args) {
	$vms += get-vm $arg
}


#! If a VM is running, error out.
foreach ($vm in $vms) {
	$state = Out-String -Stream -InputObject $vm.state
	
	if ($vm.state -ne "Off"){
		echo "Error: $vm : can only compress when off. Exiting."
		exit
	}
}


#! Find the VHDs associated with each VM
foreach ($vm in $vms){
	# Get the VHD attributes associated with the VM
	$vmid       = $vm | select-object vmid
	$vhd        = $vmid | get-vhd
	$vhdfile    = get-item $vhd.path
	$vhdoldsize = $vhd.size
	
	#! Verify that the VM has a virtual hard disk with a VHD extension
	if ($vhdfile.Extension -ne ".vhd"){
		echo "Error: ${vm.name} does not have a virtual hard disk with a .vhd extension. Skipping."
		continue
	}
	
	$vhdx = $vhd.path + "x"
	$orig = $vhd.path + ".orig"
	
	echo "Processing $vhdfile:"
	echo "   Converting to VHDX..."
	Convert-VHD -Path $vhd.path -DestinationPath $vhdx -VHDType Dynamic
	
	echo "   Backing up..."
	Move-Item -Force $vhd.path $orig
	
	echo "   Mounting..."
	Mount-VHD $vhdx -ReadOnly
	
	echo "   Compacting..."
	Optimize-VHD $vhdx -Mode full
	
	echo "   Dismounting..."
	Dismount-VHD $vhdx
	
	echo "   Resizing..."
	Resize-VHD $vhdx -ToMinimumSize
	
	echo "   Converting back to VHD..."
	Convert-VHD -Path $vhdx -DestinationPath $vhd.path -VHDType Dynamic -DeleteSource
	
	echo "   Setting proper VM permissions..."
	$path = Out-String -Stream -InputObject $vhd.path
	$vmid = Out-string -Stream -InputObject $vmid.vmid.guid
	echo "icacls `"$path`" /grant `"NT VIRTUAL MACHINE\$vmid`":(F)`n" | Set-Content -Encoding ASCII .\permissions.bat
	cmd /c .\permissions.bat
	Remove-Item .\permissions.bat
}
