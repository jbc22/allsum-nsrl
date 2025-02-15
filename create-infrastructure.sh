# Import the existing public key
public_key_base64=$(base64 ~/.ssh/id_rsa.pub)
aws lightsail import-key-pair --key-pair-name "nsrl-key-pair" --public-key-base64 "$public_key_base64"

#Create compute instance
aws lightsail create-instances --instance-names "nsrl-webserver" \
  --availability-zone us-west-2a \
  --blueprint-id ubuntu_20_04 \
  --bundle-id micro_1_0 \
  --key-pair-name "nsrl-key-pair"

#Create and attach static IP
aws lightsail allocate-static-ip --static-ip-name "nsrl-static-ip"
aws lightsail attach-static-ip --instance-name "nsrl-webserver" --static-ip-name "nsrl-static-ip"

#Create additional storage and attach
aws lightsail create-disk --disk-name "extra-storage" --size-in-gb 1024 --availability-zone us-west-2a
aws lightsail attach-disk --disk-name "extra-storage" --instance-name "nsrl-webserver" --disk-path "/dev/xvdf"

# Import the existing public key
public_key_base64=$(base64 ~/.ssh/id_rsa.pub)
aws lightsail import-key-pair --key-pair-name "nsrl-key-pair" --public-key-base64 "$public_key_base64"

# Get the public IP address of the instance
instance_ip=$(aws lightsail get-instance --instance-name "nsrl-webserver" --query 'instance.publicIpAddress' --output text)

# Wait for the instance to be ready
sleep 5

#SSH to the compute instance and mount the additional storage
#Might have to do this part manually
ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ubuntu@$instance_ip << EOF
lsblk  # Check available disks
sudo mkfs.ext4 /dev/xvdf  # Format the disk (replace xvdf with your disk name)
sudo mkdir /mnt/data  # Create mount point
sudo mount /dev/xvdf /mnt/data  # Mount the disk
EOF

echo "All done with setup!"
echo "The public IP address of the instance is: $instance_ip"
echo "Connect with: ssh ubuntu@$instance_ip"


sudo apt install nginx -y
sudo systemctl start nginx  # Start the web server
sudo systemctl enable nginx  # Start the web server on boot
sudo systemctl status nginx  # Check the status of the web server

# Create a simple HTML file 
cat << EOF > index.html
<!DOCTYPE html> 
<html>      

<head>

<title>NSRL Web Server</title>



</head>

<body>  
body {background-color: powderblue;}
<h1>Welcome to the NSRL Web Server</h1>
<p>This is a simple web server running on a Lightsail instance.</p>
</body>

</html>

EOF

# Move the HTML file to the web server directory
sudo mv index.html /var/www/html/index.html

# Restart the web server
sudo systemctl restart nginx

# Open the web server in a browser
echo "You can now access the web server at: http://$instance_ip"

# Install certbot
sudo apt install certbot python3-certbot-apache -y
sudo certbot --nginx

# Set up a cron job to automatically renew the SSL certificate
(crontab -l 2>/dev/null; echo "0 0,12 * * * certbot renew --quiet") | crontab -

