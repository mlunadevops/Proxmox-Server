How to use the script:

VARIABLES:

MOUNT_POINT="/mnt/shared1"
REMOTE_PATH="//10.0.30.1/Backup101"
DOMAIN="DJEN"

SOFTWARE DEPENDENCIES IN PROXMOX SERVER (PVE):

1) install cifs-utils: This downloads and installs the specific package needed to handle CIFS (Common Internet File System), which is the protocol Windows uses for sharing folders (SMB).

sudo apt update && sudo apt install cifs-utils -y

2) Network & Permissions: Shared folder in Windows //10.0.30.1/Backup101:

SMB Connectivity: The Proxmox node must have network access to 10.0.30.1 on ports 445 and 139

3) Mount Point: The directory /mnt/shared1 must exist on the Proxmox Backup Server before running the script.

sudo mkdir -p /mnt/shared1

4) Script Permissions: The script file must be executable.

chmod +x backup1.sh

--------------------------------

COMMAND REFERENCE:

1) Manual Mount Command: Use this to manually connect to your Windows share.

sudo mount -t cifs "//10.0.30.1/Backup101" /mnt/shared1 \ -o username="{USER}",password="{PASS}",domain="DJEN",vers=3.0

* **Shared folder (Windows):** //10.0.30.1/Backup101
* **Folder local (Proxmox VE):** /mnt/shared1
* **Username:** Windows User with privileges...
* **Password "{PASS}"**: Windows Password with privileges in the Shared folder (Windows)...

Shared folder (Windows): //10.0.30.1/Backup101 Folder local (Proxmox VE)..

/mnt/shared1 Username "{USER}": Windows User with privileges in the Shared folder (Windows)  
Password "{PASS}": Windows Password with privileges in the Shared folder (Windows)  
domain "DJEN": Windows domain Active Directory name.  


2) Manual Backup Command: Use this to trigger a snapshot backup directly to the mount point

vzdump {VM_ID} --dumpdir /mnt/shared1 --mode snapshot --compress zstd

VM ID {VM_ID}: VM ID Folder local (Proxmox VE); /mnt/shared5 Mode: snapshot Compress: zstd


--------------------------------
