# phpMyAdmin Installation Script for Pterodactyl

This script automates the installation of **phpMyAdmin** into the `public` folder of a Pterodactyl panel, typically used for accessing and managing your MySQL databases via a web interface.

## What the Script Does

- Downloads the specified version of phpMyAdmin.
- Installs required packages (`unzip`).
- Extracts phpMyAdmin into the Pterodactyl `public/phpmyadmin` directory.
- Sets correct file permissions for the web server (`www-data`).
- Configures `config.inc.php` with:
  - A generated Blowfish secret.
  - A temporary directory setting.
- Checks if the MySQL root user has a password set:
  - If not, sets one using `mysql_native_password`.
- Cleans up temporary files.

## Target Directory

phpMyAdmin will be installed in:

```
/var/www/pterodactyl/public/phpmyadmin
```

You can access it from your browser at:

```
https://your-domain.com/phpmyadmin
```

## Requirements

- Ubuntu or Debian-based system
- sudo privileges
- MySQL or MariaDB installed
- Pterodactyl panel already installed under `/var/www/pterodactyl`

## Root Password Configuration

The script will check whether the MySQL root password is empty. If it is, it will set a new password using the following SQL:

```sql
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('YourSecurePasswordHere');
FLUSH PRIVILEGES;
```

You can change the value of `MYSQL_ROOT_PASSWORD` at the top of the script.

## How to Use

1. Open a terminal on your server.
2. Save the script to a file, for example:

```bash
nano install_phpmyadmin.sh
```

3. Paste the script contents into the file.
4. Make it executable:

```bash
chmod +x install_phpmyadmin.sh
```

5. Run the script:

```bash
./install_phpmyadmin.sh
```

6. Once complete, navigate to `https://your-domain.com/phpmyadmin` in your browser.

## Manual Steps After Installation

If needed, adjust your web server configuration (Nginx/Apache) to allow access to `/phpmyadmin` under the `public` directory.

## Important Notes

- Do **not** expose the phpMyAdmin panel to the public internet without proper access controls.
- Use strong MySQL root passwords and secure your database with firewalls and fail2ban where applicable.
- The script does **not** set up SSL – it assumes SSL is already handled by your Pterodactyl panel.

---

**Author**: Your Name  
**License**: MIT  
