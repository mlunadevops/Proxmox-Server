# TECHNICAL LOG & AUTOMATION ENGINEERING GUIDE

## Configuring PBS From Scratch (This script must be run on Proxmox Backup Server.)
## Automated ZFS Pool & PBS Datastore Creator
**Miguelangel Luna**
---

## CONTENT:

[Comunity Scripts](https://community-scripts.org/scripts/post-pbs-install?id=post-pbs-install&category=Proxmox%20&%20Virtualization=)

## 1. Introduction and Theoretical Framework:

**This scripts (prepare.sh)**: create a datastore and prepare the physical disk in **RAID 1** or alone if you want.

This script streamlines the post-installation storage setup for Proxmox Backup Server. It detects the system disk to prevent accidental wipes, configures ZFS (Single or Mirror), and integrates the new storage directly into the PBS management system.

## Context and problem:


This process is repetitive, prone to human error (especially the risk of deleting the OS disk), and not standardized across installations. The script automates the entire flow with prior security validations.

## Variables (User Input):

Variable	Origen	Descripción	Ejemplo / Valores:


## Key Funcionalities:

**Intelligent OS Detection:** Uses **lsblk** and **findmnt** to identify the physical disk hosting the root partition (even on LVM) to ensure it is never formatted by mistake.

## Use Case:

Use this script when you need to connect a Proxmox VE (PVE) node to your Backup Server. Instead of sharing the master password, you create a unique user for that specific node and its designated storage.

## Logic & Flow:

**Verification:** Checks the health of the pool and confirms registration within the PBS environment.

Script detects and displays the available physical disks in PBS, allows you to create a **RAID 1** in software with the disks you specify, and will create a **ZFS datastore** (the place where backups will be stored). The variables that the user must add are:

Script Overview (prepare.sh): Automated ZFS Pool & PBS Datastore Creator:

![Flujo](images/preparedisk.svg)


## 2. IMPLEMENTATION:

This script provides options for managing Proxmox VE repositories, including disabling the Enterprise Repo, adding or correcting PVE sources, enabling the No-Subscription Repo, adding the test Repo, disabling the subscription nag, updating Proxmox VE, and rebooting the system.

**2.1)** Run the following command:

```text
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh)"
```

![PVE Post-Install](images/01PBS.png)

**2.2) This scripts (prepare.sh), create a datastore and prepare the physical disk in RAID 1 or alone if you want.**

```text
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mlunadevops/Proxmox-Backup-Server-Tools/main/1.prepare%20disks/prepare.sh)"
```
![Implementar Datastores](images/02curl.png)

## 3. USER OUTPUTS:

Pantallas:

**3.1)** Displays the available physical disks.

 <img width="576" height="240" alt="image" src="https://github.com/user-attachments/assets/3f83d1ed-9d16-4df8-a5fe-bc8860eea372" />

**3.2)** Requests the variables:

**EMAIL:** The email address where Proxmox Backup Server (PBS) will send alerts.

**DISK_A_RAW:** The identifier of the first physical disk you want to use.

**DISK_B_RAW:** The identifier of the second disk (only if creating a Mirror).

**POOL_NAME:** A custom name for your new ZFS storage pool and PBS datastore.

<img width="649" height="333" alt="image" src="https://github.com/user-attachments/assets/99cede99-7303-443e-9109-e6b02d58f254" />


