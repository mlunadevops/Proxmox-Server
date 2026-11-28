# TECHNICAL LOG & AUTOMATION ENGINEERING GUIDE

## Configuring PBS From Scratch
**CCNP Miguelangel Luna**

---

## CONTENT:


[Comunity Scripts](https://community-scripts.org/scripts/post-pbs-install?id=post-pbs-install&category=Proxmox%20&%20Virtualization=)

## 1. Introduction and Theoretical Framework

**Proxmox Backup Server:** Performs backup and restoration of VMs, containers, and physical hosts, and is characterized by its high efficiency, security, and support for off-site storage. Feactures:

**Deduplication and incrementals:** PBS divides data into blocks and removes duplicates, storing only the blocks that have changed since the previous backup.

**Security and encryption:** It supports client-side encryption (AES-256-GCM), data is encrypted before being sent to the server.

**Verification:** It incorporates **SHA-256** verification to guarantee data integrity and prevent silent data corruption.

**Remote synchronization and tapes:** It enables efficient data synchronization between remote sites **(it only transfers the differences)**.

## 2. Topology and BGP Neighbor Establishment

![BGP WEIGTH](images/01Topologia.jpg)

## 3. IMPLEMENTATION:

The script is designed for Proxmox Backup Server (PBS) and will give options to Disable the Enterprise Repo, Add/Correct PBS Sources, Enable the No-Subscription Repo, Add Test Repo, Disable Subscription Nag, Update Proxmox Backup Server and Reboot PBS:

**1.1)** Run the following command:

```text
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pbs-install.sh)"
```

![PBS Post-Install](images/01PBS.png)

**1.2) This scripts (prepare.sh), create a datastore and prepare the physical disk in RAID 1 or alone if you want.**

```text
cd csr1kv
```






