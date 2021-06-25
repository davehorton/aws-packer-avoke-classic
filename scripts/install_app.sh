#!/bin/bash

cd /home/admin
mkdir apps
cp /tmp/avoke-fork.tgz apps
cp /tmp/ecosystem.config.js apps
cd apps 
tar xvfz avoke-fork.tgz && rm avoke-fork.tgz

cd /home/admin/apps/avoke-fork && sudo npm install --unsafe-perm

sudo -u admin bash -c "pm2 install pm2-logrotate"
sudo -u admin bash -c "pm2 set pm2-logrotate:max_size 1G"
sudo -u admin bash -c "pm2 set pm2-logrotate:retain 5"
sudo -u admin bash -c "pm2 set pm2-logrotate:compress true"

sudo chown -R admin:admin  /home/admin/apps

pm2 start /home/admin/apps/ecosystem.config.js
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u admin --hp /home/admin
sudo -u admin bash -c "pm2 save"
sudo systemctl enable pm2-admin.service
