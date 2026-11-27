# TECHNICAL LOG & AUTOMATION ENGINEERING GUIDE

## Configuring PBS From Scratch
**CCNP Miguelangel Luna**

---

## CONTENT:

| Case | Title | Description |
| :--- | :--- | :--- |
| **01** | [Claude & n8n AI Agents](./case-01-Google-Auth/) | Agentes Claude . |

[Comunity Scripts](https://community-scripts.org/scripts/post-pbs-install?id=post-pbs-install&category=Proxmox%20&%20Virtualization=)

## 1. Introduction and Theoretical Framework

**pyATS =** The infrastructure for organizing, running, and reporting automated network tests in a professional way.

## 2. Topology and BGP Neighbor Establishment

![BGP WEIGTH](images/01Topologia.jpg)

## 3. IMPLEMENTATION:

The script is designed for Proxmox Backup Server (PBS) and will give options to Disable the Enterprise Repo, Add/Correct PBS Sources, Enable the No-Subscription Repo, Add Test Repo, Disable Subscription Nag, Update Proxmox Backup Server and Reboot PBS:

**1.1)** Run the following command:

```text
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pbs-install.sh)"
```

![PBS Post-Install](images/01PBS.png)



**1.2) Enter the virtual environment:**

```text
cd csr1kv
```






