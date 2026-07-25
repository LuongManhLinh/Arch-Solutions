#!/usr/bin/env bash

WAYBAR_DIR="$HOME/.config/waybar"
CONF_DIR="$WAYBAR_DIR/configs"
STYLE_DIR="$WAYBAR_DIR/style"
SETTINGS_FILE="$WAYBAR_DIR/.selected"

# Ensure settings file exists
if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo 'CONFIG=""' > "$SETTINGS_FILE"
    echo 'STYLE=""' >> "$SETTINGS_FILE"
fi

# Load current selections
# shellcheck disable=SC1090
source "$SETTINGS_FILE"

echo "=== Current selections ==="
echo "Config: ${CONFIG:-<None>}"
echo "Style : ${STYLE:-<None>}"
echo

# Choose config
echo "=== Available Waybar Configurations ==="
configs=("$CONF_DIR"/*)
for i in "${!configs[@]}"; do
    base=$(basename "${configs[$i]}")
    echo "$((i+1)). $base"
done
read -rp "Select a config number: " conf_choice
conf_file="${configs[$((conf_choice-1))]}"
[[ -f "$conf_file" ]] || { echo "Invalid config. You had one job."; exit 1; }
CONFIG=$(basename "$conf_file")

# Choose style
echo -e "\n=== Available Waybar Styles ==="
styles=("$STYLE_DIR"/*)
for i in "${!styles[@]}"; do
    base=$(basename "${styles[$i]}")
    echo "$((i+1)). $base"
done
read -rp "Select a style number: " style_choice
style_file="${styles[$((style_choice-1))]}"
[[ -f "$style_file" ]] || { echo "Invalid style. Just tragic."; exit 1; }
STYLE=$(basename "$style_file")

echo -e "\nApplying selections..."

# Copy files
cp "$conf_file" "$WAYBAR_DIR/config" || exit 1
cp "$style_file" "$WAYBAR_DIR/style.css" || exit 1

# Save to settings
{
    echo "CONFIG=\"$CONFIG\""
    echo "STYLE=\"$STYLE\""
} > "$SETTINGS_FILE"

# Restart waybar
pkill waybar 2>/dev/null
waybar & disown

echo "Done. At least the computer, unlike you, knows what it is doing."
