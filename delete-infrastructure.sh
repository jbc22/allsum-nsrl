aws lightsail delete-instance --instance-name "nsrl-webserver"
aws lightsail delete-disk --disk-name "extra-storage"
aws lightsail release-static-ip --static-ip-name "nsrl-static-ip"


aws lightsail get-instances                                      
aws lightsail get-disks
aws lightsail get-static-ips
aws lightsail get-disk-snapshots
