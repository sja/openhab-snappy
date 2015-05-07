#!/bin/sh

# Debugging:
#set -x

workdir=/apps/openhab/1.6.2/openhab
cd $workdir

export JAVA_HOME="/apps/openhab/current/jdk"

openhab_home=/var/lib/apps/openhab/1.6.2
config_location=${openhab_home}/configurations

# Check if the configuration is in writable area, otherwise copy it there
if [ ! -d "$openhab_home/configurations" ]; then
	mkdir -p ${openhab_home}/configurations
	cp -r ${workdir}/configurations ${workdir}/etc $openhab_home
	cp ${config_location}/openhab_default.cfg ${config_location}/openhab.cfg
fi

# set path to eclipse folder. If local folder, use '.'; otherwise, use /path/to/eclipse/
eclipsehome=$(workdir)/server

# set ports for HTTP(S) server
HTTP_PORT=8080
HTTPS_PORT=8443

# get path to equinox jar inside $eclipsehome folder
launcher=$(find $eclipsehome -name "org.eclipse.equinox.launcher_*.jar" | sort | tail -1);

if [ -z "$launcher" ]; then
	>&2 echo "Error: could not find equinox launcher."
	exit 1
fi

echo Launching the openHAB runtime...
$JAVA_HOME/bin/java \
	-Dosgi.clean=true \
	-Declipse.ignoreApp=true \
	-Dosgi.noShutdown=true  \
	-Djetty.port=$HTTP_PORT  \
	-Djetty.port.ssl=$HTTPS_PORT \
	-Djetty.home=${workdir}  \
	-Dlogback.configurationFile=${config_location}/logback.xml \
	-Dfelix.fileinstall.dir=${workdir}/addons \
	-Dfelix.fileinstall.filter=.*\\.jar \
	-Djava.library.path=${workdir}/lib \
	-Djava.security.auth.login.config=${openhab_home}/etc/login.conf \
	-Dorg.quartz.properties=${openhab_home}/etc/quartz.properties \
	-Dequinox.ds.block_timeout=240000 \
	-Dequinox.scr.waitTimeOnBlock=60000 \
	-Dfelix.fileinstall.active.level=4 \
	-Djava.awt.headless=true \
	-Dopenhab.configdir=${config_location} \
	-Dopenhab.configfile=${config_location}/openhab.cfg \
	-jar $launcher \
	-configuration ${openhab_home} \
	-console
