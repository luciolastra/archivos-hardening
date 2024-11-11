#!/bin/bash

cp /nftables-AMI.conf /etc/nftables.conf

systemctl start nftables
systemctl enable nftables
