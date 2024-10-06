#!/bin/bash

# Eliminar paquetes de Bluetooth

apt remove --purge -y bluez
apt autoremove -y
