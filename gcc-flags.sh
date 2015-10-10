#!/bin/bash
#
#! Lists the command line flags that are native to this machine.

gcc -### -E - -march=native 2>&1 | sed -r '/cc1/!d;s/(")|(^.* - )//g'

