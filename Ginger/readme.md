


1. Software Dependencies in Proxmox Backup Server:
   
sudo apt update && sudo apt install cifs-utils -y

2. Network & Permissions: Shared folder in Windows //10.0.30.5/2019:

SMB Connectivity: The Proxmox node must have network access to 10.0.30.5 on ports 445 and 139

3. Mount Point: The directory /mnt/shared5 must exist on the Proxmox Backup Server before running the script.

sudo mkdir -p /mnt/shared5

4.Script Permissions: The script file must be executable.
