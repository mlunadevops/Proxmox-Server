
A Hidden "Secrets" File
Instead of putting the token in the script, we will put it in a separate file that only the root user can read.

Step 1: Create the Secrets File, Create a hidden file in the root directory:

sudo nano /root/.pve_api_token

Step 2: Add your Token, paste your token into this file and save it:

root@pam!RESTORE_TOKEN=xxxx-xxxx-xxxx-xxxx

Step 3: Secure the File This is the most important step. We will change the "Permissions" so that only the root user can see the file. No one else on the system can read it.

sudo chmod 600 /root/.pve_api_token

--------------------------

Requiriments:

# 1. Create the file and paste your token inside (Format: root@pam!ID=SECRET)
echo "root@pam!RESTORE_TOKEN=your-secret-here" > /root/.pve_api_token

# 2. Lock the file so only root can read it
chmod 600 /root/.pve_api_token

-------------------------------------

<img width="960" height="527" alt="api" src="https://github.com/user-attachments/assets/6dd290a3-cd26-49c1-ac71-9b2ebe590e10" />
