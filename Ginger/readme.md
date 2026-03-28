How to use the script:
1)


1. Software Dependencies in Proxmox Backup Server:
   
sudo apt update && sudo apt install cifs-utils -y

2. Network & Permissions: Shared folder in Windows //10.0.30.5/2019:

SMB Connectivity: The Proxmox node must have network access to 10.0.30.5 on ports 445 and 139

3. Mount Point: The directory /mnt/shared5 must exist on the Proxmox Backup Server before running the script.

sudo mkdir -p /mnt/shared5

4.Script Permissions: The script file must be executable.

chmod +x your_script_name.sh

Command reference:

1. Manual Mount Command: Use this to manually connect to your Windows share.
   
sudo mount -t cifs "//10.0.30.5/2019" /mnt/shared5 \ -o username="{USER}",password="{PASS}",domain="DJEN",vers=3.0

Shared folder (Windows): //10.0.30.5/2019
Folder local (Proxmox VE); /mnt/shared5
Username "{USER}": Windows User with privileges in the Shared folder (Windows)
Password "{PASS}": Windows Password with privileges in the Shared folder (Windows)
domain "DJEN": Windows Active Directory name

2. Manual Backup Command: Use this to trigger a snapshot backup directly to the mount point

vzdump {VM_ID} --dumpdir /mnt/shared5 --mode snapshot --compress zstd

VM ID {VM_ID}: VM ID
Folder local (Proxmox VE); /mnt/shared5
Mode: snapshot
Compress: zstd

