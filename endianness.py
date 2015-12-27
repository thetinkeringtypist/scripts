#!/usr/bin/env python3
#
#!  Author: Bezeredi, Evan D.
#
#! A script to determine the byteorder (endianness) of this machine
import sys


#! Main function
def main():
	print(sys.byteorder + " endian")

	return


#! Run the main function
if __name__ == '__main__':
	main()
