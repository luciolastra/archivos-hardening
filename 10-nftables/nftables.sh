#!/bin/bash

cp /nftables.conf /etc/nftables.conf

systemctl start nftables
systemctl enable nftables
