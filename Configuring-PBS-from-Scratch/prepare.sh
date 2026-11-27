#!/bin/bash
set -u

if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Please run this script as root or with sudo."
    exit 1
fi

# --- 1. DETECT SYSTEM DISK ---
ROOT_SRC=$(findmnt -nvo SOURCE / 2>/dev/null)
SYSTEM_DISK=""
if [[ -n "$ROOT_SRC" ]]; then
    PARENT_1=$(lsblk -no PKNAME "$ROOT_SRC" 2>/dev/null | head -n1)
    if [[ -n "$PARENT_1" ]]; then
        PARENT_2=$(lsblk -no PKNAME "/dev/$PARENT_1" 2>/dev/null | head -n1)
        SYSTEM_DISK="${PARENT_2:-$PARENT_1}"
    fi
fi

if [[ -z "$SYSTEM_DISK" ]]; then
    SYSTEM_DISK=$(lsblk -rno NAME,MOUNTPOINT | awk '$2 == "/" {print $1}' | sed -E 's/p?[0-9]+$//')
fi

# --- 2. DISPLAY DISK INFO ---
echo "Current Disk Configuration:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS
echo "----------------------------------------------------------"
echo "WARNING: OS / root mount is associated with: ${SYSTEM_DISK:-unknown}"
echo "----------------------------------------------------------"

# --- 3. INTERACTIVE USER VARIABLES ---
read -rp "Enter your notification email: " EMAIL
read -rp "Enter the FIRST disk (e.g., sda or sdb): " DISK_A_RAW
read -rp "Enter the SECOND disk for a mirror (leave empty for single disk): " DISK_B_RAW
read -rp "Enter the name for your new ZFS pool: " POOL_NAME

DISK_A_NAME="${DISK_A_RAW#/dev/}"
DISK_B_NAME="${DISK_B_RAW#/dev/}"

# --- 4. SAFETY & LOGIC CHECKS ---
if [[ -z "$DISK_A_NAME" || ! -b "/dev/$DISK_A_NAME" ]]; then
    echo "ERROR: First disk '/dev/$DISK_A_NAME' does not exist."
    exit 1
fi

if [[ -n "$SYSTEM_DISK" && ( "$DISK_A_NAME" == "$SYSTEM_DISK" || "$DISK_B_NAME" == "$SYSTEM_DISK" ) ]]; then
    echo "ERROR: Critical safety stop! You cannot use the system disk ($SYSTEM_DISK)."
    exit 1
fi

if [[ -z "$DISK_B_NAME" ]]; then
    MODE="SINGLE"
    DISK_A="/dev/$DISK_A_NAME"
    echo "Mode selected: SINGLE DISK on $DISK_A"
elif [[ "$DISK_A_NAME" == "$DISK_B_NAME" ]]; then
    echo "ERROR: You cannot mirror a disk to itself."
    exit 1
else
    if [[ ! -b "/dev/$DISK_B_NAME" ]]; then
        echo "ERROR: Second disk '/dev/$DISK_B_NAME' does not exist."
        exit 1
    fi
    MODE="MIRROR"
    DISK_A="/dev/$DISK_A_NAME"
    DISK_B="/dev/$DISK_B_NAME"
    echo "Mode selected: ZFS MIRROR on $DISK_A and $DISK_B"
fi

# --- 5. FINAL CONFIRMATION ---
read -rp "WARNING: Proceed with wiping data and creating ZFS pool '$POOL_NAME'? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Exiting without changes."
    exit 1
fi

# --- 6. APPLY CONFIGURATION ---
if [[ -n "$EMAIL" ]]; then
    echo "Configuring notification email..."
    proxmox-backup-manager user update root@pam --email "$EMAIL" || { echo "ERROR: Failed to update email."; exit 1; }
fi

echo "Wiping disk signatures..."
wipefs -a "$DISK_A" || { echo "ERROR: Failed to wipe $DISK_A."; exit 1; }
if [[ "$MODE" == "MIRROR" ]]; then
    wipefs -a "$DISK_B" || { echo "ERROR: Failed to wipe $DISK_B."; exit 1; }
fi

echo "Creating ZFS pool ($MODE)..."
if [[ "$MODE" == "MIRROR" ]]; then
    zpool create -f -o ashift=12 "$POOL_NAME" mirror "$DISK_A" "$DISK_B" || { echo "ERROR: Failed to create mirror pool."; exit 1; }
else
    zpool create -f -o ashift=12 "$POOL_NAME" "$DISK_A" || { echo "ERROR: Failed to create single-disk pool."; exit 1; }
fi

zfs set compression=lz4 "$POOL_NAME" || { echo "ERROR: Failed to set compression."; exit 1; }
zfs set atime=off "$POOL_NAME" || { echo "ERROR: Failed to disable atime."; exit 1; }

echo "Registering PBS datastore..."
proxmox-backup-manager datastore create "$POOL_NAME" "/$POOL_NAME" || { echo "ERROR: Failed to register datastore."; exit 1; }

# --- 7. VERIFICATION SECTION ---
echo "----------------------------------------------------------"
echo "VERIFYING DEPLOYMENT..."
echo "----------------------------------------------------------"

ZFS_STATUS=$(zpool list -H -o health "$POOL_NAME" 2>/dev/null)
echo "ZFS Pool '$POOL_NAME' Status: ${ZFS_STATUS:-UNKNOWN}"

if proxmox-backup-manager datastore list | grep -qw "$POOL_NAME"; then
    echo "PBS Datastore Registration: SUCCESS"
else
    echo "PBS Datastore Registration: FAILED"
    exit 1
fi

df -h "/$POOL_NAME"

echo "----------------------------------------------------------"
echo "Setup complete! Pool '$POOL_NAME' is ready."
