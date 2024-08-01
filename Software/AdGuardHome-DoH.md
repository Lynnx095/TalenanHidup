# AdGuard Home Installation and DNS-over-HTTPS (DoH) Setup

This guide will walk you through the installation of AdGuard Home and the setup of DNS-over-HTTPS (DoH) for secure DNS queries.

## Prerequisites:

- A VPS or server with a public IP address.
- Basic knowledge of command-line operations.
- Domain name that you own.

## Steps:

### 1. Install AdGuard Home

To simplify the installation process, you can use an automated script:

1. **Connect to your VPS:**

   Use SSH to connect to your VPS:
   ```bash
   ssh username@your_vps_ip
   ```

2. **Run the installation script:**

   Execute the following command to download and run the installation script for AdGuard Home:
   ```bash
   curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
   ```

   This command downloads the installation script and runs it with the `-v` flag to install the latest version of AdGuard Home.

3. **Access the AdGuard Home web interface:**

   Once the installation is complete, open your web browser and navigate to:
   ```
   http://your_vps_ip:3000
   ```

   Follow the setup wizard to configure AdGuard Home.

### 2. Prepare a Domain

1. **Purchase a domain** if you haven't already. Use a domain registrar of your choice (e.g., Namecheap, GoDaddy).

2. **Log in to your domain registrar’s control panel.**

### 3. Change Your Domain Nameserver (NS) to Cloudflare

1. **Sign up for a Cloudflare account** at [Cloudflare](https://www.cloudflare.com/).

2. **Add your domain to Cloudflare:**

   - Log in to Cloudflare and click "Add a Site."
   - Enter your domain name and click "Add Site."
   - Choose a plan and click "Confirm Plan."

3. **Update nameservers:**

   Cloudflare will provide you with two nameservers. Go to your domain registrar’s control panel and replace your current nameservers with those provided by Cloudflare.

4. **Verify nameserver change:**

   It may take some time for the changes to propagate. You can check the status using online tools like [What's My DNS](https://www.whatsmydns.net/).

### 4. Setup Certificate for the Domain Using `legoagh`

Follow these steps to obtain and configure an SSL/TLS certificate using the `legoagh` script:

1. **Download the `legoagh` Script:**

   Use `wget` or `curl` to download the script to your server:
   ```bash
   wget https://raw.githubusercontent.com/ameshkov/legoagh/master/legoagh.sh
   ```
   Or with `curl`:
   ```bash
   curl -O https://raw.githubusercontent.com/ameshkov/legoagh/master/legoagh.sh
   ```

2. **Make the Script Executable:**

   Change the permissions to make the script executable:
   ```bash
   chmod +x legoagh.sh
   ```

3. **Run the Script:**

   Execute the script with root privileges to start the certificate issuance process:
   ```bash
   sudo ./legoagh.sh
   ```

4. **Follow the Interactive Prompts:**

   The script will prompt you for various details. Provide the following:

   - **Email Address:** For certificate notifications and recovery.
     ```plaintext
     Enter your email address (e.g., your-email@example.com):
     ```

   - **Domain Name(s):** For the certificate. You can specify multiple domains by separating them with commas.
     ```plaintext
     Enter your domain name(s) (e.g., example.com,www.example.com):
     ```

   - **DNS Provider:** Choose your DNS provider from the list. This is required for DNS-01 challenges to verify domain ownership.
     ```plaintext
     Select your DNS provider:
     ```

   - **API Credentials:** If your DNS provider requires API credentials, enter them when prompted. These credentials can usually be found in your DNS provider’s control panel.

5. **Verify Installation:**

   Once the script completes, it will place the certificate files in the `/etc/lego/` directory (or the directory specified during the setup). Typical files include:
   - `cert.pem` (The certificate)
   - `privkey.pem` (The private key)
   - `fullchain.pem` (The full certificate chain)

   Verify the presence of these files:
   ```bash
   ls /etc/lego/certificates/
   ```

6. **Configure AdGuard Home to Use the Certificate:**

   Update AdGuard Home’s configuration to use the new certificate files. You may need to specify the paths to `cert.pem`, `privkey.pem`, and `fullchain.pem` in the AdGuard Home configuration file.

7. **Restart AdGuard Home:**

   To apply the new certificates, restart AdGuard Home:
   ```bash
   sudo systemctl restart AdGuardHome
   ```

8. **Verify HTTPS Setup:**

   Ensure that AdGuard Home is properly serving content over HTTPS by visiting the web interface:
   ```
   https://yourdomain.com:3000
   ```

   Check for a valid SSL/TLS certificate in your browser without any warnings.

9. **Automate Certificate Renewal:**

   The `legoagh` script should configure automatic certificate renewals. Verify the renewal setup by checking the scheduled tasks:
   ```bash
   sudo crontab -l
   ```
   or
   ```bash
   systemctl list-timers
   ```

   Ensure there is a scheduled task for renewing the certificates.

### 5. Point A Record to the VPS IP Address

1. **Log in to the Cloudflare dashboard.**

2. **Navigate to the DNS settings for your domain.**

3. **Add an A record:**

   - **Type:** A
   - **Name:** @ (or use `www` if you want `www.yourdomain.com` to also point to your VPS)
   - **IPv4 address:** Your VPS IP address
   - **TTL:** Auto

4. **Save the changes.**

   Allow some time for DNS propagation.

