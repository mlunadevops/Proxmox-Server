
A Hidden "Secrets" File
Instead of putting the token in the script, we will put it in a separate file that only the root user can read.

Step 1: Create the Secrets File, Create a hidden file in the root directory:

sudo nano /root/.pve_api_token

Step 2: Add your Token, paste your token into this file and save it:

root@pam!RESTORE_TOKEN=xxxx-xxxx-xxxx-xxxx

Step 3: Secure the File This is the most important step. We will change the "Permissions" so that only the root user can see the file. No one else on the system can read it.

sudo chmod 600 /root/.pve_api_token

