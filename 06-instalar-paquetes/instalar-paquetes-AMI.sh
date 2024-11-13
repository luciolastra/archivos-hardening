#!/bin/bash

# Instalar paquetes sugeridos por Lynis para mejorar el hardening.
apt install -y libpam-tmpdir apt-listbugs needrestart debsums apt-show-versions fail2ban aide acct unattended-upgrades auditd audispd-plugins
