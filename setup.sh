#!/bin/bash

# Variables
APP_DIR="/var/s3-nodejs-app"
SERVICE_NAME="s3-nodejs-app"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# Step 1: Update the system and install required packages
echo "Updating system and installing required packages..."
sudo yum update -y
sudo yum install -y nodejs npm

# Step 2: Create the application directory
echo "Creating application directory..."
sudo mkdir -p $APP_DIR
sudo chown -R ec2-user:ec2-user $APP_DIR

# Step 3: Copy app files to the application directory
echo "Copying app files to $APP_DIR..."
cp -r . $APP_DIR
sudo chown -R ec2-user:ec2-user $APP_DIR

# Verify package.json exists
if [ ! -f "$APP_DIR/package.json" ]; then
    echo "Error: package.json is missing in $APP_DIR"
    exit 1
fi

# Step 4: Install Node.js dependencies
echo "Installing Node.js dependencies..."
cd $APP_DIR
npm install

# Step 5: Create the systemd service file
echo "Creating systemd service file..."
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Node.js S3 App
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/node $APP_DIR/app.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Step 6: Reload systemd and enable the service
echo "Reloading systemd and enabling the service..."
sudo systemctl daemon-reload
sudo systemctl start $SERVICE_NAME
sudo systemctl enable $SERVICE_NAME

# Step 7: Check the status of the service
echo "Checking the status of the service..."
sudo systemctl status $SERVICE_NAME

echo "Setup complete! Your Node.js app should now be running."

