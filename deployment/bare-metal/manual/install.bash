#!/bin/bash

# This is the standard (non-interactive) installation process of the GNU Health
# server (https://en.wikibooks.org/wiki/GNU_Health/Installation). We are using a
# bundled database here, but it could be easily changed to support e.g. remote
# postgres.

set -euxo pipefail

GNUHEALTH_VERSION=3.6.2

GNUHEALTH_LOG_CONF=$( cat ${HOME}/health-demo/deployment/bare-metal/manual/files/gnuhealth_log.conf )
TRYTOND_CONF=$( cat ${HOME}/health-demo/deployment/bare-metal/manual/files/trytond.conf )

# Install GNU Health dependencies.
apt-get update
apt-get install postgresql patch python3-pip unoconv -y
# GNU Health installation process starts here.
adduser --disabled-password --gecos "" gnuhealth
su - postgres -c "createuser --createdb --no-createrole --no-superuser gnuhealth"
su - gnuhealth -c "wget https://ftp.gnu.org/gnu/health/gnuhealth-${GNUHEALTH_VERSION}.tar.gz"
# Verifying the package signature *could* be skipped.
su - gnuhealth -c "gpg --keyserver hkps://keyserver.ubuntu.com --recv-key 0xC015E1AE00989199"
su - gnuhealth -c "gpg --with-fingerprint --list-keys 0xC015E1AE00989199"
su - gnuhealth -c "wget https://ftp.gnu.org/gnu/health/gnuhealth-${GNUHEALTH_VERSION}.tar.gz.sig"
su - gnuhealth -c "gpg --verify gnuhealth-${GNUHEALTH_VERSION}.tar.gz.sig gnuhealth-${GNUHEALTH_VERSION}.tar.gz"
su - gnuhealth -c "tar xzf gnuhealth-${GNUHEALTH_VERSION}.tar.gz"
su - gnuhealth \
    -c "cd gnuhealth-${GNUHEALTH_VERSION} && \
        wget -qO- https://ftp.gnu.org/gnu/health/gnuhealth-setup-latest.tar.gz | tar -xzvf - && \
        bash ./gnuhealth-setup install"
# Write config files.
su - gnuhealth \
    -c "source \${HOME}/.gnuhealthrc && \
        echo \"${GNUHEALTH_LOG_CONF}\" > \${GNUHEALTH_DIR}/tryton/server/config/gnuhealth_log.conf && \
        echo \"${TRYTOND_CONF}\" > \${GNUHEALTH_DIR}/tryton/server/config/trytond.conf"
# For the sake of the demo - populate database with demo content.
su - gnuhealth -c "cd gnuhealth-${GNUHEALTH_VERSION}/scripts/demo && ./install_demo_database.sh 36"
