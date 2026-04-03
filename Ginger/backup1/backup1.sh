#!/bin/bash

# --- Variables ---
MOUNT_POINT="/mnt/shared1"
REMOTE_PATH="//10.0.30.1/Backup101"
DOMAIN="DJEN"

# 1. Gather User Input Securely
read -p "Enter Windows Username: " WIN_USER
read -sp "Enter Password for $WIN_USER: " WIN_PASS
echo -e "\n"
read -p "Enter VM ID to backup (e.g., 101): " VM_ID

# 2. Check Mount Persistence
if mountpoint -q "$MOUNT_POINT"; then
    echo "[!] $MOUNT_POINT is already mounted."
else
    echo "[+] Attempting to mount $REMOTE_PATH..."
    sudo mount -t cifs "$REMOTE_PATH" "$MOUNT_POINT" \
        -o username="$WIN_USER",password="$WIN_PASS",domain="$DOMAIN",vers=3.0
    
    if [ $? -ne 0 ]; then
        echo "[✘] Error: Connection failed."
        exit 1
    fi
    echo "[✓] Mount successful."
fi

# 3. INTERACTIVE DELETION LOOP (FORCED RESTART)
while true; do
    # Clear the previous array and re-scan the folder
    unset files
    mapfile -t files < <(ls $MOUNT_POINT/*vzdump-qemu-$VM_ID* 2>/dev/null)

    # If no files found, exit the loop
    if [ ${#files[@]} -eq 0 ]; then
        echo -e "\nNo more backups found for VM $VM_ID."
        break 
    fi

    echo -e "\n--- Current Backups for VM $VM_ID ---"
    for i in "${!files[@]}"; do
        echo "[$i] $(basename "${files[$i]}")"
    done

    echo "----------------------------------------------------"
    read -p "Enter the number to DELETE (or press ENTER to finish): " FILE_INDEX
    
    # If the input is empty, break the loop and move to verification
    if [[ -z "$FILE_INDEX" ]]; then
        echo "[i] Selection finished."
        break
    fi

    # Validate if it's a number and within the range
    if [[ "$FILE_INDEX" =~ ^[0-9]+$ ]] && [ "$FILE_INDEX" -lt "${#files[@]}" ]; then
        TARGET_FILE="${files[$FILE_INDEX]}"
        rm -f "$TARGET_FILE"
        echo "[✓] Deleted: $(basename "$TARGET_FILE")"
        # We don't break here; the loop starts over automatically
    else
        echo "[!] Invalid selection. Please try again."
    fi
done

# 4. FINAL VERIFICATION
echo -e "\n--- VERIFICATION: Final folder state ---"
ls -lh "$MOUNT_POINT" | grep "$VM_ID" || echo "No files remain for VM $VM_ID."

# 5. Execute Backup
echo -e "\nReady to proceed with backup for VM $VM_ID?"
read -p "Type 'yes' to confirm and start: " CONFIRM

if [[ "$CONFIRM" == "yes" ]]; then
    echo -e "\n[+] Starting backup..."
    vzdump "$VM_ID" --dumpdir "$MOUNT_POINT" --mode snapshot --compress zstd
else
    echo "[!] Operation cancelled."
fi
