# Fixing SDDM Black Screen Issue on Arch Linux (KDE)

If your system boots into a black screen at the login prompt and you suspect it's due to SDDM misconfiguration or theme issues, follow these steps to resolve it.

## Steps to Fix

### 1. Access a TTY Session
Use a TTY session to access your system:
```bash
Ctrl + Alt + F3
```
Log in with your username and password.

### 2. Revert to the Default SDDM Theme
Edit the SDDM configuration file:
```bash
sudo nano /etc/sddm.conf
```
Make sure it contains the default Breeze theme:
```ini
[Theme]
Current=breeze
```
Save the file (`Ctrl + O`), then exit (`Ctrl + X`).

### 3. Restart the SDDM Service
Disable and re-enable the SDDM service:
```bash
sudo systemctl disable sddm
sudo systemctl enable sddm
sudo systemctl start sddm
```

After doing these steps, the SDDM login screen should reappear and function normally.

## Notes
- If the problem persists, consider checking your graphics drivers and system journal logs:
```bash
journalctl -u sddm --no-pager
```
- You can try using a different greeter theme or reinstalling `sddm` and `plasma` packages if needed.

---

This markdown file documents the process of fixing a black screen issue caused by SDDM misconfiguration on Arch Linux.

