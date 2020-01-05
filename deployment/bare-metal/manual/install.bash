#!/bin/bash

# This is the standard (non-interactive) installation process of the GNU Health
# server (https://en.wikibooks.org/wiki/GNU_Health/Installation). We are using a
# bundled database here, but it could be easily changed to support e.g. remote
# postgres.

set -euxo pipefail

GNUHEALTH_VERSION=3.6.2

GNUHEALTH_LOG_CONF=$( cat ${HOME}/health-demo/deployment/bare-metal/manual/files/gnuhealth_log.conf )
TRYTOND_CONF=$( cat ${HOME}/health-demo/deployment/bare-metal/manual/files/trytond.conf )

# Root access is mandatory.
sudo -i
# Install GNU Health dependencies.
apt-get update
apt-get install postgresql patch python3-pip unoconv -y
# GNU Health installation process starts here.
adduser --disabled-password --gecos "" gnuhealth
su - gnuhealth
cd ${HOME}
wget https://ftp.gnu.org/gnu/health/gnuhealth-${GNUHEALTH_VERSION}.tar.gz
# Verifying the package signature *could* be skipped.
gpg --keyserver hkps://keyserver.ubuntu.com --recv-key 0xC015E1AE00989199
gpg --with-fingerprint --list-keys 0xC015E1AE00989199
wget https://ftp.gnu.org/gnu/health/gnuhealth-${GNUHEALTH_VERSION}.tar.gz.sig
gpg --verify gnuhealth-${GNUHEALTH_VERSION}.tar.gz.sig gnuhealth-${GNUHEALTH_VERSION}.tar.gz
tar xzf gnuhealth-${GNUHEALTH_VERSION}.tar.gz
cd gnuhealth-${GNUHEALTH_VERSION}
wget -qO- https://ftp.gnu.org/gnu/health/gnuhealth-setup-latest.tar.gz | tar -xzvf -
bash ./gnuhealth-setup install
source ${HOME}/.gnuhealthrc
# Write config files.
echo "${GNUHEALTH_LOG_CONF}" > ${GNUHEALTH_DIR}/tryton/server/config/gnuhealth_log.conf
echo "${TRYTOND_CONF}" > ${GNUHEALTH_DIR}/tryton/server/config/trytond.conf
# For the sake of the demo - populate database with demo content.
cd ${GNUHEALTH_DIR}/scripts/demo
./install_demo_database.sh 36
