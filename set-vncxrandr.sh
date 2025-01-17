#!/bin/bash

function usage() {
    echo "Usage: $0 <width>x<height>"
    echo "Example: $0 2560x1024"
    exit 1
}

# Check if argument is provided
if [ -z "$1" ]; then
    usage
fi

RESOLUTION=$1

# Parse the width and height from the input
WIDTH=$(echo $RESOLUTION | cut -d'x' -f1)
HEIGHT=$(echo $RESOLUTION | cut -d'x' -f2)

# Default refresh rate
REFRESH_RATE=30

# Get the display name (you may need to adjust based on your setup)
DISPLAY_NAME=$(xrandr | grep ' connected' | awk '{print $1}')

# Check if a valid display was found
if [ -z "$DISPLAY_NAME" ]; then
    echo "No connected display found."
    exit 1
else
    echo "Found display: $DISPLAY_NAME"
fi

# Check if resolution already exists
MODE_NAME=$(xrandr | grep -E "${WIDTH}x${HEIGHT}" | awk '{print $1}')

if [ ! -z "$MODE_NAME" ]; then
    echo "Resolution ${WIDTH}x${HEIGHT} already exists as mode ${MODE_NAME}."
else
    echo "Adding new resolution ${WIDTH}x${HEIGHT}"
    MODE_INFO=$(cvt $WIDTH $HEIGHT $REFRESH_RATE | grep "Modeline" | cut -d' ' -f3-)
    if [ ! -z "$MODE_INFO" ]; then
        echo "...Tech spec: $MODE_INFO"
        xrandr --newmode "${WIDTH}x${HEIGHT}" $MODE_INFO &> /dev/null
    else
        echo "Failed to generate modeline for $RESOLUTION"
        exit 1
    fi
    MODE_NAME="${WIDTH}x${HEIGHT}"
fi

# Set the resolution using xrandr
xrandr --addmode $DISPLAY_NAME $MODE_NAME
xrandr --output $DISPLAY_NAME --mode $MODE_NAME

echo "Resolution set to ${WIDTH}x${HEIGHT} at ${REFRESH_RATE}Hz on display $DISPLAY_NAME"