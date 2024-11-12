#! /bin/bash
#
# Navigate to /root folder and start the tmux session
#
cd /root

IP_REALTIME_MACHINE=$1
IP_HOST=$2



env IP_REALTIME_MACHINE=$IP_REALTIME_MACHINE IP_HOST=$IP_HOST tmuxp load /root/start_app.yaml
