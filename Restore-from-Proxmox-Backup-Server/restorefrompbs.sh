#!/bin/bash

# --- 1. Configuration ---
PVE_NODE="proxmox"           # Your PVE hostname
PVE_URL="https://localhost:8006/api2/json"
TOKEN_FILE="/root/.pve_api_token"
EMAIL_RECEIVER="your-email@example.com" # <--- UPDATE THIS

# --- 2. Security Check ---
if [ ! -f "$TOKEN_FILE" ]; then
    echo "[✘] Error: Token file not found at $TOKEN_FILE"
    exit 1
fi

API_TOKEN=$(cat "$TOKEN_FILE")

# --- 3. List & Select PBS Storage ---
echo "--- Fetching PBS Storages from PVE ---"
storage_json=$(curl -s -k -H "Authorization: PVEAPIToken=$API_TOKEN" "$PVE_URL/storage")
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

# --- 4. List & Select Backup Snapshot ---
read -p "Enter VM ID to restore (e.g. 101): " VM_ID
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

# --- 5. Confirmation & Execution ---
echo -e "\n[!] WARNING: This will overwrite VM $VM_ID with $SELECTED_SNAP"
read -p "Type 'yes' to confirm: " CONFIRM

if [[ "$CONFIRM" == "yes" ]]; then
    START_TIME=$(date)
    echo "[+] Starting restore process..."
    
    # Executing the restore
    if qmrestore "$SELECTED_SNAP" "$VM_ID" --force 1 --unique 0; then
        STATUS="SUCCESS"
        ICON="[✓]"
    else
        STATUS="FAILED"
        ICON="[✘]"
    fi
    END_TIME=$(date)

    # --- 6. Send Email Report ---
    echo "Sending email report to $EMAIL_RECEIVER..."
    echo -e "Restore Report for VM $VM_ID\n\nStatus: $STATUS\nSnapshot: $SELECTED_SNAP\nStorage: $SELECTED_STORAGE\nStarted: $START_TIME\nFinished: $END_TIME" | mail -s "Proxmox Restore $STATUS: VM $VM_ID" "$EMAIL_RECEIVER"

    echo "$ICON Restore $STATUS. Summary sent."
else
    echo "[!] Operation cancelled."
fi
