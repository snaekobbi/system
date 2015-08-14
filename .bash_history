sudo -u pipeline2 /opt/daisy-pipeline2/bin/pipeline2 shell
sudo service pipeline2d stop
sudo service pipeline2-webuid start
sudo rm /var/opt/daisy-pipeline2-webui/webui/RUNNING_PID
ps -ef | grep java | grep -v grep | awk '{print $2}' | xargs sudo kill
