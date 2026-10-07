# TECHNICAL LOG & RESTORE FROM PBS

## Script for new PVE Servers
**CCNP Miguelangel Luna**
---

## CONTENIDOS:

| Case | Title | Description |
| :--- | :--- | :--- |
| **01** | [Claude & n8n AI Agents](./case-01-Google-Auth/) | Agentes Claude . |
| **02** | [Packet Tracert & VS CODE](./case-02-PT-MCP-VS-Code/) | Conecta Packet Tracert con MCP |
| **03** | [Generar un Archivo Word desde Markdown usando Phyton](./case-03-Markdown-Word-Using-Phyton/) | Convierte un MD a Word usando Phyton |
| **04** | [GNS3 AI](./case04-GNS3-AI/) | Conexion GNS3 MCP. |

[Google](https://www.google.com)

## 1. Introduction and Theoretical Framework

The Weight attribute is a Cisco proprietary parameter used in BGP (Border Gateway Protocol) for best path selection. Its main characteristics are:

* **Local Scope:** It has meaning exclusively within the local router where it is configured and is not propagated via BGP routing updates to neighbors.
* **Value Range:** An integer number between 0 and 65,535.
* **Default Values:** Routes originated locally by the router receive a weight of 32,768 by default; routes learned from external or internal neighbors receive a weight of 0 by default.
* **Precedence:** It is evaluated in the absolute first place within BGP's decision algorithm (above Local Preference, AS_PATH, MED, etc.). Routes with a higher Weight value have absolute preference.

## 2. Topology and BGP Neighbor Establishment

The topology consists of four routers across different Autonomous Systems (AS 100, AS 200, AS 300, and AS 400). Before advertising prefixes, BGP neighbor adjacencies were established on each device.

![BGP WEIGTH](images/01Topologia.jpg)

 four routers across different Autonomous Systems (AS 100, AS 200, AS 300, and AS 400). Before advertising prefixes, BGP neighbor adjacencies were established on each device.

## 3. BGP Configuration:

**Router A (RTA - AS 100):**

```text
! 
router bgp 100
!
```

### 4. BGP Configuration:








Este script debe correrse en Proxmox Server donde vas a restaurar el backup desde el Proxmox Backup Server

A Hidden "Secrets" File
Instead of putting the token in the script, we will put it in a separate file that only the root user can read.

Step 1: Create the Secrets File, Create a hidden file in the root directory:

sudo nano /root/.pve_api_token

Step 2: Add your Token, paste your token into this file and save it:

root@pam!RESTORE_TOKEN=xxxx-xxxx-xxxx-xxxx

Step 3: Secure the File This is the most important step. We will change the "Permissions" so that only the root user can see the file. No one else on the system can read it.

sudo chmod 600 /root/.pve_api_token

--------------------------
 Install:

 apt update && apt install jq -y

------------------------------
Requiriments:

# 1. Create the file and paste your token inside (Format: root@pam!ID=SECRET)
echo 'root@pam!RESTORE_TOKEN=mysecret' > /root/.pve_api_token

# 2. Lock the file so only root can read it
chmod 600 /root/.pve_api_token

-------------------------------------

DATACENTER - PERMISSIONS - TOKEN

<img width="960" height="527" alt="api" src="https://github.com/user-attachments/assets/6dd290a3-cd26-49c1-ac71-9b2ebe590e10" />
<img width="470" height="155" alt="token" src="https://github.com/user-attachments/assets/c4f4cae6-3ec7-4582-befd-ca96d32f311e" />
