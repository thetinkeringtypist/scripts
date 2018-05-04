#!/bin/bash
#
#! A Script to find my public IP address

IP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{print $2}')

echo "This machine's public IP is $IP"
