#!/bin/bash
VERSION=v1.10.5
LWS_VERSION=v3.2.3

echo "freeswitch version to install is ${VERSION}"
echo "LWS_VERSION version to install is ${LWS_VERSION}"

git config --global pull.rebase true
cd /usr/local/src
git clone https://github.com/signalwire/freeswitch.git -b ${VERSION}
git clone https://github.com/warmcat/libwebsockets.git -b ${LWS_VERSION}
git clone https://github.com/drachtio/drachtio-freeswitch-modules.git -b master

cd freeswitch/libs

git clone https://github.com/freeswitch/spandsp.git -b master
git clone https://github.com/freeswitch/sofia-sip.git -b master
git clone https://github.com/dpirch/libfvad.git

sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_audio_fork /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork
 
sudo sed -i -r -e 's/(.*AM_CFLAGS\))/\1 -g -O0/g' /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork/Makefile.am
sudo sed -i -r -e 's/(.*-std=c++11)/\1 -g -O0/g' /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork/Makefile.am

# build libwebsockets
cd /usr/local/src/libwebsockets
sudo mkdir -p build && cd build && sudo cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && sudo make && sudo make install

# build libfvad
cd /usr/local/src/libfvad
sudo autoreconf -i && sudo ./configure && sudo make -j 4 && sudo make install

# build spandsp
cd /usr/local/src/freeswitch/libs/spandsp
./bootstrap.sh && ./configure && make -j 4 && sudo make install

# build sofia
cd /usr/local/src/freeswitch/libs/sofia-sip
./bootstrap.sh && ./configure && make -j 4 && sudo make install

# copy Makefiles into place
cp /tmp/configure.ac.lws /usr/local/src/freeswitch/configure.ac
cp /tmp/Makefile.am.lws /usr/local/src/freeswitch/Makefile.am
cp /tmp/modules.conf.in.lws /usr/local/src/freeswitch/build/modules.conf.in
cp /tmp/modules.conf.vanilla.xml.lws /usr/local/src/freeswitch/conf/vanilla/autoload_configs/modules.conf.xml
cp /tmp/switch_rtp.c.patch /usr/local/src/freeswitch/src

# patch freeswitch
cd /usr/local/src/freeswitch/src
patch < switch_rtp.c.patch

# build freeswitch
echo "building freeswitch"
cd /usr/local/src/freeswitch
sudo ./bootstrap.sh -j
sudo ./configure --with-lws=yes
sudo make -j 4
sudo make install
sudo make cd-sounds-install cd-moh-install
sudo cp /tmp/acl.conf.xml /usr/local/freeswitch/conf/autoload_configs
sudo cp /tmp/event_socket.conf.xml /usr/local/freeswitch/conf/autoload_configs
sudo cp /tmp/switch.conf.xml /usr/local/freeswitch/conf/autoload_configs
sudo cp /tmp/conference.conf.xml /usr/local/freeswitch/conf/autoload_configs
sudo rm -Rf /usr/local/freeswitch/conf/dialplan/*
sudo rm -Rf /usr/local/freeswitch/conf/sip_profiles/*
sudo cp /tmp/mrf_dialplan.xml /usr/local/freeswitch/conf/dialplan
sudo cp /tmp/mrf_sip_profile.xml /usr/local/freeswitch/conf/sip_profiles
sudo cp /usr/local/src/freeswitch/conf/vanilla/autoload_configs/modules.conf.xml /usr/local/freeswitch/conf/autoload_configs
sudo cp /tmp/freeswitch.service /etc/systemd/system
sudo chown root:root -R /usr/local/freeswitch
sudo chmod 644 /etc/systemd/system/freeswitch.service
sudo sed -i -e 's/global_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8/global_codec_prefs=PCMU,PCMA,OPUS,G722/g' /usr/local/freeswitch/conf/vars.xml
sudo sed -i -e 's/outbound_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8/outbound_codec_prefs=PCMU,PCMA,OPUS,G722/g' /usr/local/freeswitch/conf/vars.xml
sudo systemctl enable freeswitch
sudo cp /tmp/freeswitch_log_rotation /etc/cron.daily/freeswitch_log_rotation
sudo chown root:root /etc/cron.daily/freeswitch_log_rotation
sudo chmod a+x /etc/cron.daily/freeswitch_log_rotation
