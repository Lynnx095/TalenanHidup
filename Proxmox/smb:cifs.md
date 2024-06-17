
---

# Proxmox SMB/CIFS Mount Setup Instructions

1. **SSH to Proxmox Console:**
   To access the Proxmox console from another PC via SSH, follow these steps:
   - Open your terminal or command prompt.
   - Use the following command:
     ```
     ssh root@<your_proxmox_ip>
     ```
     Replace `<your_proxmox_ip>` with the actual IP address of your Proxmox server.

2. **Create Necessary Folders:**
   Ensure that you've already created the necessary folders for Proxmox to work. These folders include:
   - `dump`
   - `template`
   - `private`
   - `images`
   - `iso`

3. **Manually Connect to NAS:**
   If you need to mount a network-attached storage (NAS) device, use the following command:
   ```
   mount -t cifs //10.10.10.100/HomeServer/Proxmox /mnt/pve/NAS -o username=user,password=pass,uid=1000,gid=1000
   ```
   Replace `10.10.10.100` with your NAS IP address, and adjust the credentials accordingly.

4. **Add SMB/CIFS Share via Web UI:**
   - Log in to the Proxmox web interface.
   - Navigate to the "Datacenter" or "Storage" section.
   - Add a new storage resource using the SMB/CIFS protocol.
   - Provide the necessary details, including the NAS path and credentials.


---