#!/bin/bash

# --- 1. Configuration ---
PVE_NODE="proxmox" 
API_TOKEN="root@pam!RESTORE_TOKEN=xxxx-xxxx-xxxx"
PVE_URL="https://localhost:8006/api2/json"
EMAIL_RECEIVER="your-email@example.com" # <--- ADD YOUR EMAIL HERE

# --- 2. List & Select PBS Storage ---
echo "--- Fetching PBS Storages ---"
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

# --- 3. List & Select Backup Snapshot ---
read -p "Enter VM ID to restore: " VM_ID
echo "--- Searching PBS for VM $VM_ID snapshots ---"

backup_json=$(curl -s -k -H "Authorization: PVEAPIToken=$API_TOKEN" "$PVE_URL/nodes/$PVE_NODE/storage/$SELECTED_STORAGE/content")
mapfile -t snapshots < <(echo "$backup_json" | jq -r --arg vmid "$VM_ID" '.data[] | select(.volid | contains("vm/" + $vmid + "/")) | .volid')

if [ ${#snapshots[@]} -eq 0 ]; then
    echo "[✘] No snapshots found for VM $VM_ID."
    exit 1
fi

echo "Select the snapshot to RESTORE:"
for i in "${!snapshots[@]}"; do
    echo "[$i] ${snapshots[$i]}"
done
read -p "Enter number: " SNAP_INDEX
SELECTED_SNAP=${snapshots[$SNAP_INDEX]}

# --- 4. Confirmation & Execution ---
echo -e "\n[!] WARNING: Overwriting VM $VM_ID with $SELECTED_SNAP"
read -p "Type 'yes' to confirm: " CONFIRM

if [[ "$CONFIRM" == "yes" ]]; then
    START_TIME=$(date)
    echo "[+] Starting restore..."
    
    # Run the restore and capture the result
    if qmrestore "$SELECTED_SNAP" "$VM_ID" --force 1 --unique 0; then
        STATUS="SUCCESS"
        ICON="[✓]"
    else
        STATUS="FAILED"
        ICON="[✘]"
    fi
    END_TIME=$(date)

    # --- 5. Send Email Report ---
    echo "Sending email report to $EMAIL_RECEIVER..."
    echo -e "Restore Report for VM $VM_ID\n\nStatus: $STATUS\nSnapshot: $SELECTED_SNAP\nStorage: $SELECTED_STORAGE\nStarted: $START_TIME\nFinished: $END_TIME" | mail -s "Proxmox Restore $STATUS: VM $VM_ID" "$EMAIL_RECEIVER"

    echo "$ICON Restore $STATUS. Summary sent to $EMAIL_RECEIVER."
else
    echo "[!] Operation cancelled."
fi
