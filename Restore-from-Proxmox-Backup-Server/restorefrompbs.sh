#!/bin/bash

# --- 1. Automated Node Detection ---
PVE_NODE=$(hostname)
PVE_URL="https://localhost:8006/api2/json"
TOKEN_FILE="/root/.pve_api_token"

echo "-------------------------------------------------------"
echo "   Proxmox Restore Utility - Node: $PVE_NODE"
echo "-------------------------------------------------------"

# --- 2. Interactive Email Setup ---
read -p "Enter the Email Address for the report: " EMAIL_RECEIVER

# --- 3. Security & Token Check ---
if [ ! -f "$TOKEN_FILE" ]; then
    echo -e "\n[✘] ERROR: Token file not found at $TOKEN_FILE"
    echo "-------------------------------------------------------"
    echo "To fix this, please run the following command as root:"
    echo "echo 'root@pam!ID=SECRET' > $TOKEN_FILE"
    echo "chmod 600 $TOKEN_FILE"
    echo "-------------------------------------------------------"
    exit 1
fi

API_TOKEN=$(cat "$TOKEN_FILE")

# --- 4. List & Select PBS Storage ---
echo -e "\n--- Fetching PBS Storages from PVE ---"
storage_json=$(curl -s -k -H "Authorization: PVEAPIToken=$API_TOKEN" "$PVE_URL/storage")

# Validate API connection
if [[ $(echo "$storage_json" | jq -r '.data') == "null" ]]; then
    echo "[✘] API Connection Failed. Check your Token ID and Secret."
    exit 1
fi

mapfile -t pbs_list < <(echo "$storage_json" | jq -r '.data[] | select(.type == "pbs") | .storage')

if [ ${#pbs_list[@]} -eq 0 ]; then
    echo "[✘] No Proxmox Backup Server storage found."
    exit 1
fi

echo "Select your PBS Datastore:"
for i in "${!pbs_list[@]}"; do
    echo "[$i] ${pbs_list[$i]}"
done
read -p "Enter number: " STORAGE_INDEX
SELECTED_STORAGE=${pbs_list[$STORAGE_INDEX]}

# --- 5. List & Select Backup Snapshot ---
echo ""
read -p "Enter VM ID to restore (e.g., 101): " VM_ID
echo "--- Searching for VM $VM_ID snapshots in $SELECTED_STORAGE ---"

backup_json=$(curl -s -k -H "Authorization: PVEAPIToken=$API_TOKEN" "$PVE_URL/nodes/$PVE_NODE/storage/$SELECTED_STORAGE/content")
mapfile -t snapshots < <(echo "$backup_json" | jq -r --arg vmid "$VM_ID" '.data[] | select(.volid | contains("vm/" + $vmid + "/")) | .volid')

if [ ${#snapshots[@]} -eq 0 ]; then
    echo "[✘] No snapshots found for VM $VM_ID."
    exit 1
fi

echo "Select the snapshot to RESTORE (Replacing current VM):"
for i in "${!snapshots[@]}"; do
    echo "[$i] ${snapshots[$i]}"
done
read -p "Enter number: " SNAP_INDEX
SELECTED_SNAP=${snapshots[$SNAP_INDEX]}

# --- 6. Confirmation & Execution ---
echo -e "\n[!] WARNING: This will overwrite VM $VM_ID with $SELECTED_SNAP"
read -p "Type 'yes' to confirm: " CONFIRM

if [[ "$CONFIRM" == "yes" ]]; then
    START_TIME=$(date)
    echo "[+] Starting restore process..."
    
    if qmrestore "$SELECTED_SNAP" "$VM_ID" --force 1 --unique 0; then
        STATUS="SUCCESS"
        ICON="[✓]"
    else
        STATUS="FAILED"
        ICON="[✘]"
    fi
    END_TIME=$(date)

    # --- 7. Send Email Report ---
    echo "Sending email report to $EMAIL_RECEIVER..."
    echo -e "Restore Report for VM $VM_ID\n\nStatus: $STATUS\nNode: $PVE_NODE\nSnapshot: $SELECTED_SNAP\nStorage: $SELECTED_STORAGE\nStarted: $START_TIME\nFinished: $END_TIME" | mail -s "Proxmox Restore $STATUS: VM $VM_ID" "$EMAIL_RECEIVER"

    echo "$ICON Restore $STATUS. Summary sent."
else
    echo "[!] Operation cancelled."
fi
