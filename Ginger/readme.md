# Technical Documentation: Automated VM Restoration from Proxmox Backup Server (PBS)

## Traffic Manipulation via the Weight Attribute
**Miguelangel Luna**

---

[Proxmox Backup Server](https://www.proxmox.com/en/downloads/proxmox-backup-server)

## 1. Introduction and Theoretical Framework

### Proxmox Backup Server (PBS):
Proxmox Backup Server is an open-source enterprise backup solution designed to back up and restore virtual machines (VMs), containers (CTs), and physical hosts. It utilizes **chunk-based deduplication, meaning only new or modified blocks of data are stored during each backup, drastically reducing disk space usage and optimizing network bandwidth.**

### Virtual Machine Recovery Process
Recovering (restoring) a VM involves rebuilding its virtual disks and configuration files from a snapshot stored on the PBS. The standard process in Proxmox VE (PVE) relies on native commands such as `qmrestore` and low-level tools (`pbs-restore`), which:
1. Query metadata and block indexes of the backup from the remote server.
2. Allocate the required virtual volumes in the local node storage (e.g., `local-lvm`).
3. Discover and concurrently download missing data chunks from the PBS repository to write them to the target disks.

### The `jq` Tool
`jq` is a lightweight and flexible command-line JSON processor. In the context of this script, it is completely indispensable because the Proxmox VE REST API responds exclusively in JSON format. `jq` allows you to filter, parse, and extract specific data—such as available PBS storage lists or snapshot identifiers—cleanly inside shell scripts.

---

## 2. Prerequisites
Before deploying and executing the script on any new Proxmox VE server, ensure the following requirements are met:
1. **Proxmox VE Connected to PBS:** The PVE node must have the Proxmox Backup Server storage added to its configuration.
2. **Dependency Installation (`jq`):** The JSON processor must be present on the base operating system.
3. **Proxmox API Token:** An authentication token with administrator privileges is required to interact with the local API without needing plain-text passwords.

## 3. Implementation and Deployment Steps
Follow these steps on any new Proxmox VE server to make the restoration script fully operational:

### Step 1: Install the `jq` Dependency
Run the following command in the terminal to install the JSON processor:

**JQ Tool (pve shell)**

```text
apt update && apt install -y jq
```

### Step 2: Create the API Token in Proxmox VE
To allow the script to communicate with the Proxmox API automatically:
1. Access the Proxmox VE web interface.
2. Navigate to **Datacenter** > **Permissions** > **API Tokens** > **Add**.
3. Configure the following parameters:
   - **User:** `root@pam`
   - **Token ID:** `restore-script`
   - **Privilege Separation:** Uncheck (to inherit full root permissions).
4. Copy the generated **Secret** value (it is only shown once).



![BGP WEIGTH](images/01Topologia.jpg)

 


### 4. BGP Configuration:















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

