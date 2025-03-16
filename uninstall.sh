#!/bin/bash

# Variables
APP_DIR="/var/s3-nodejs-app"
SERVICE_NAME="s3-nodejs-app"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

echo "Stopping and disabling the service..."
sudo systemctl stop $SERVICE_NAME
sudo systemctl disable $SERVICE_NAME

echo "Removing application files..."
sudo rm -rf $APP_DIR

echo "Removing systemd service file..."
sudo rm -f $SERVICE_FILE

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Uninstallation complete!"

