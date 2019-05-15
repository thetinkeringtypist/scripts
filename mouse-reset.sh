#!/bin/sh
#
#! My Amazon Basics wireless mouse frequently stops responding. This script
#  resets the wireless reciever used by the mouse.
sudo usb_modeswitch --reset-usb -v 0x04f2 -p 0x0976
