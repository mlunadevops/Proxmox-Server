# TECHNICAL LOG & PROXMOX SERVER

## Traffic Manipulation via the Weight Attribute
**CCNP Miguelangel Luna**

---

## CONTENIDOS:

| Case | Title | Description |
| :--- | :--- | :--- |
| **01** | [Claude & n8n AI Agents](./case-01-Google-Auth/) | Agentes Claude . |

[Google](https://www.google.com)

## 1. Introduction and Theoretical Framework

## 1. PAM Realm vs. PVE Realm

Proxmox manages different types of authentication called realms:

![BGP WEIGTH](images/00pam&pve.jpg)

* **Linux PAM Realm (`pam`):** Authenticates directly against the underlying host operating system users (those that exist in `/etc/passwd` and `/etc/shadow`).
* **Proxmox VE Realm (`pve`):** Uses Proxmox's own internal database (`/etc/pve/user.cfg`) managed through the web interface or CLI, independent of Linux system users.

> **Technical Note:** PAM is used to authenticate users against the underlying Linux operating system accounts (the Proxmox host).

**Important Considerations:**

* **User creation:** For a user to log in via PAM, you must first create them at the system level on the Proxmox host using standard Linux commands (such as `useradd` or `adduser`).
* **Permissions:** Although the user authenticates through Linux PAM, specific permissions for VM, containers, or storage must be configured within Proxmox (`Datacenter -> Permissions`).

## 2. Topology and BGP Neighbor Establishment





 four routers across different Autonomous Systems (AS 100, AS 200, AS 300, and AS 400). Before advertising prefixes, BGP neighbor adjacencies were established on each device.

## 3. BGP Configuration:

**Router A (RTA - AS 100):**

```text
! 
router bgp 100
!
```

### 4. BGP Configuration:
