#!/bin/bash

DEPLOY_TARGET="/home/deploy/avoke-fork/config"

# Assume root is running this, should make sure deploy has rights to
# avoke-fork/config/ directory

# If deploy is running, don't update system/freeswitch files.

export PROJECT=$(/usr/bin/curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)

# Emit basic information on environment
echo "Running: ${0}, user: ${USER}, project ${PROJECT}, branch ${RUNNING_BRANCH:=master}."
TDIR=$(/bin/mktemp --directory /tmp/setup.XXXXXXXXXX)

# Grab latest dialplan repo snapshot
/usr/bin/gcloud source repos clone dialplan $TDIR --project=ce-avoke-prod-01
RC=$?
if [ $RC -ne 0 ]
then
    echo "Error: unable to clone dialplan (see previous messages.)"
    exit $RC
fi

# Make sure the correct/specified branch is checked out.
(cd $TDIR; /usr/bin/git checkout $RUNNING_BRANCH)

# This will be non-null if changes left in dialplans (config/) directory
EXISTING=$(ls ${DEPLOY_TARGET}/*~ 2>/dev/null; ls ${DEPLOY_TARGET}/*.hold 2>/dev/null)
if [ "$EXISTING" ]
then
    echo "*Warning: updated artifacts remaining in config directory, "
    echo "          not updating from repo."
else
    cp -v ${TDIR}/${PROJECT}/local.json ${DEPLOY_TARGET}/local.json
    sudo -u deploy /usr/bin/pm2 restart all
fi

# That's all if there is no "override" directory for this project.
if [ ! -d ${TDIR}/profiles/${PROJECT} ]
then
    exit
fi

# If we're not running as root, don't attempt to modify Freeswitch configs.
if [ $USER != 'root' ]
then
    echo "Note: not running as root, will not update other configuration."
    exit 0
fi

# Is there a specific override file for the freeswitch vars (vars.xml)?
then
    echo "Note: not running as root, will not update other configuration."
    exit 0
fi

# Is there a specific override file for the freeswitch vars (vars.xml)?
# deploy_files ${TDIR}/profiles/${PROJECT}/freeswitch /usr/local/freeswitch/conf
if [ -e ${TDIR}/profiles/${PROJECT}/freeswitch/vars.xml ]
then
    cp -v ${TDIR}/profiles/${PROJECT}/freeswitch/vars.xml /usr/local/freeswitch/conf/.
    systemctl restart freeswitch.service
fi

# Is there a specific override file for the systemd unit?
# deploy_units ${TDIR}/profiles/${PROJECT}/systemd /etc/systemd/system
if [ -e ${TDIR}/profiles/${PROJECT}/systemd/drachtio.service ]
then
    cp -v ${TDIR}/profiles/${PROJECT}/systemd/drachtio.service /etc/systemd/system/.
    systemctl daemon-reload
    systemctl restart drachtio.service
fi
