#!/usr/bin/env python3
#
#! A script to determine the byteorder (endianness) of this machine
#
#  Author: Bezeredi, Evan D.
import sys


#! Main function
def main():
	print(sys.byteorder + " endian")

	return


#! Run the main function
if __name__ == '__main__':
	main()
