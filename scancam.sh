#!/bin/bash

echo "================================================="
echo " Advanced Local Network Camera Detection Tool"
echo "================================================="
echo ""

# ----------------------------
# CONFIG
# ----------------------------
CAMERA_PORTS="80,81,82,83,84,85,88,443,554,8000,8001,8080,8081,8082,8554,8899,37777"
CAMERA_VENDORS="hikvision|dahua|axis|foscam|reolink|uniview|vivotek|amcrest|tp-link|ubiquiti|gopro|sony|panasonic|bosch|geovision"

TMP_DEVICES="/tmp/camera_scan_devices.txt"

# ----------------------------
# CHECK TOOLS
# ----------------------------
REQUIRED_TOOLS=("arp-scan" "nmap" "ip" "awk" "grep")

echo "[INFO] Checking required tools..."

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "[ERROR] Missing tool: $tool"
        echo "Install using:"
        echo "sudo apt install arp-scan nmap"
        exit 1
    fi
done

echo "[OK] All required tools found."
echo ""

# ----------------------------
# DETECT NETWORK INTERFACE
# ----------------------------
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)

if [ -z "$INTERFACE" ]; then
    echo "[ERROR] Could not determine network interface."
    exit 1
fi

echo "[INFO] Using interface: $INTERFACE"
echo ""

# ----------------------------
# DEVICE DISCOVERY
# ----------------------------
echo "[STEP 1] Discovering devices on local network..."

sudo arp-scan --interface=$INTERFACE --localnet > $TMP_DEVICES

DEVICE_COUNT=$(grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' $TMP_DEVICES | wc -l)

echo "[INFO] Devices detected: $DEVICE_COUNT"
echo ""

# ----------------------------
# EXTRACT IPS
# ----------------------------
IPS=$(grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' $TMP_DEVICES)

echo "[INFO] Listing discovered devices:"
cat $TMP_DEVICES
echo ""

echo "================================================="
echo " Beginning detailed analysis..."
echo "================================================="
echo ""

# ----------------------------
# ANALYSIS LOOP
# ----------------------------
for ip in $IPS
do
    echo "-------------------------------------------------"
    echo "[DEVICE] $ip"

    MAC=$(grep $ip $TMP_DEVICES | awk '{print $2}')
    VENDOR=$(grep $ip $TMP_DEVICES | cut -f3-)

    echo "[INFO] MAC Address: $MAC"
    echo "[INFO] Vendor: $VENDOR"

    # ----------------------------
    # CAMERA VENDOR CHECK
    # ----------------------------
    if echo "$VENDOR" | grep -iE "$CAMERA_VENDORS" > /dev/null
    then
        echo "[ALERT] Vendor matches known camera manufacturer!"
    fi

    # ----------------------------
    # PORT SCAN
    # ----------------------------
    echo "[STEP] Scanning common camera ports..."

    SCAN=$(nmap -p $CAMERA_PORTS --open -sV $ip)

    OPEN_PORTS=$(echo "$SCAN" | grep open)

    if [ -z "$OPEN_PORTS" ]
    then
        echo "[INFO] No typical camera ports detected."
        continue
    fi

    echo "[RESULT] Open ports:"
    echo "$OPEN_PORTS"
    echo ""

    echo "[POSSIBLE ACCESS ENDPOINTS]"

    if echo "$OPEN_PORTS" | grep -q "80/tcp"
    then
        echo "Web interface: http://$ip"
    fi

    if echo "$OPEN_PORTS" | grep -q "443/tcp"
    then
        echo "Secure web interface: https://$ip"
    fi

    if echo "$OPEN_PORTS" | grep -q "8080/tcp"
    then
        echo "Alt web interface: http://$ip:8080"
    fi

    if echo "$OPEN_PORTS" | grep -q "8000/tcp"
    then
        echo "Hikvision port: http://$ip:8000"
    fi

    if echo "$OPEN_PORTS" | grep -q "554/tcp"
    then
        echo "RTSP stream: rtsp://$ip:554"
    fi

    if echo "$OPEN_PORTS" | grep -q "8554/tcp"
    then
        echo "Alt RTSP stream: rtsp://$ip:8554"
    fi

    if echo "$OPEN_PORTS" | grep -q "8899/tcp"
    then
        echo "ONVIF port detected"
    fi

    echo ""
done

echo "================================================="
echo " Scan finished"
echo "================================================="
