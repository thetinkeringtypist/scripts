#!/bin/bash
#
#! Lists the command line flags that are native to your machine.
#
#  NOTE: This assumes that you are using gcc 4.6 or later.

gcc -### -E - -march=native 2>&1 | sed -r '/cc1/!d;s/(")|(^.* - )//g'

