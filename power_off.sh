#!/bin/sh
# file in printer/opt/config/mod_data/power_off.sh
unset LD_PRELOAD

#/opt/cloud/curl-7.55.1-https/bin/curl -k https://mail.ru

echo "Shutdown command to host..."

ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@{remote_host_address} -i /opt/config/mod_data/ssh.key "nohup {path_to}/poweroff_me2.sh black >/dev/null 2>1&1 &"
sleep 5

echo "shutdown init..."
halt -d 15
