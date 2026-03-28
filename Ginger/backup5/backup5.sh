#!/bin/bash

# --- Variables ---
MOUNT_POINT="/mnt/shared5"
REMOTE_PATH="//10.0.30.5/2019"
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
        echo "[✘] Error: Bad password or connection failed."
        exit 1
    fi
    echo "[✓] Mount successful."
fi

# 3. INTERACTIVE DELETION LOOP
while true; do
    echo -e "\n--- Current Backups for VM $VM_ID ---"
    # Refresh the file list array inside the loop
    files=($(ls $MOUNT_POINT/*vzdump-qemu-$VM_ID* 2>/dev/null))

    if [ ${#files[@]} -eq 0 ]; then
        echo "No existing backups found for VM $VM_ID."
        break # Exit loop if no files exist
    fi

    # Display numbered list
    for i in "${!files[@]}"; do
        echo "[$i] $(basename "${files[$i]}")"
    done

    read -p "Enter the number to DELETE (or press Enter to finish cleaning): " FILE_INDEX
    
    # If user presses Enter without a number, exit the loop
    if [[ -z "$FILE_INDEX" ]]; then
        break
    fi

    # Validate input and delete
    if [[ "$FILE_INDEX" =~ ^[0-9]+$ ]] && [ "$FILE_INDEX" -lt "${#files[@]}" ]; then
        rm -f "${files[$FILE_INDEX]}"
        echo "[✓] Deleted: ${files[$FILE_INDEX]}"
    else
        echo "[!] Invalid selection. Please try again."
    fi
done

# 4. FINAL VERIFICATION & CONFIRMATION
echo -e "\n--- FINAL FOLDER STATE ---"
ls -lh "$MOUNT_POINT" | grep "$VM_ID" || echo "No files remain for VM $VM_ID."

echo -e "\nReady to proceed with backup for VM $VM_ID?"
read -p "Type 'yes' to confirm and start: " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "[!] Operation cancelled."
    exit 0
fi

# 5. Execute Backup
echo -e "\n[+] Starting backup..."
vzdump "$VM_ID" --dumpdir "$MOUNT_POINT" --mode snapshot --compress zstd

if [ $? -eq 0 ]; then
    echo "[✓] Backup completed successfully."
else
    echo "[✘] Backup failed."
fi
