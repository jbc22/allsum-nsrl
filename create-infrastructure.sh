# Import the existing public key
public_key=$(cat ~/.ssh/id_rsa.pub)
aws lightsail import-key-pair --key-pair-name "nsrl-key-pair" --public-key "$public_key"

#Create compute instance with the imported key pair
aws lightsail create-instances --instance-names "nsrl-webserver" \
  --availability-zone us-west-2a \
  --blueprint-id ubuntu_24_04 \
  --bundle-id micro_1_0 \
  --key-pair-name "nsrl-key-pair"

# Wait for the instance to be in a running state
echo "Waiting for the instance to be in a running state..."
while [ "$(aws lightsail get-instance-state --instance-name nsrl-webserver --query 'state.name' --output text)" != "running" ]; do
  sleep 5
done

#Create and attach static IP
aws lightsail allocate-static-ip --static-ip-name "nsrl-static-ip"
aws lightsail attach-static-ip --instance-name "nsrl-webserver" --static-ip-name "nsrl-static-ip"

#Create additional storage and attach
aws lightsail create-disk --disk-name "extra-storage" --size-in-gb 1024 --availability-zone us-west-2a

# Wait for the disk to be in an available state
echo "Waiting for the disk to be in an available state..."
while [ "$(aws lightsail get-disk --disk-name extra-storage --query 'disk.state' --output text)" != "available" ]; do
  sleep 5
done

aws lightsail attach-disk --disk-name "extra-storage" --instance-name "nsrl-webserver" --disk-path "/dev/xvdf"

# Get the public IP address of the instance
instance_ip=$(aws lightsail get-instance --instance-name "nsrl-webserver" --query 'instance.publicIpAddress' --output text)

# Wait for the instance to be ready for SSH
sleep 15

# Retry mechanism to ensure SSH connection is ready
max_attempts=10
attempt=0
until ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ubuntu@$instance_ip "echo 'SSH connection established'" || [ $attempt -eq $max_attempts ]; do
  echo "Attempting to connect to SSH... (Attempt: $((attempt+1))/$max_attempts)"
  attempt=$((attempt+1))
  sleep 5
done

if [ $attempt -eq $max_attempts ]; then
  echo "Failed to establish SSH connection after $max_attempts attempts."
  exit 1
fi

#SSH to the compute instance and mount the additional storage
ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ubuntu@$instance_ip << EOF
lsblk  # Check available disks
sudo mkfs.ext4 /dev/xvdf  # Format the disk (replace xvdf with your disk name)
sudo mkdir /mnt/data  # Create mount point
sudo mount /dev/xvdf /mnt/data  # Mount the disk
sudo chown ubuntu:ubuntu /mnt/data  # Change ownership to ubuntu user


# Install Podman
sudo apt-get update
sudo apt-get -y install podman
EOF

# Open port 5000 for the web server
aws lightsail open-instance-public-ports \
    --instance-name "nsrl-webserver" \
    --port-info fromPort=5000,toPort=5000,protocol=TCP

echo "All done with setup!"
echo "The public IP address of the instance is: $instance_ip"
echo "Connect with: ssh -i ~/.ssh/id_rsa ubuntu@$instance_ip"