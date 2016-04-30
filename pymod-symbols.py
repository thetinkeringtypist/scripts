#!/usr/bin/env python
#
#!  Author: Bezeredi, Evan D.
#
#!  A script to determine the symbols in a given module
import sys
import os
import importlib


#! Main function
def main():
	if len(sys.argv) == 1:
		print sys.argv[0], "requires module name"
		exit()

	module_name = sys.argv[1]
	module = importlib.import_module(module_name)

	dictionary = get_module_symbols(module)
	for symbol, value in dictionary.iteritems():
		print "{:<9} = {}".format(symbol, value)
	

#! Gets the symbols and the associated values from an imported module
#  Does not show symbols whose prefixes are '_' or '__'
def get_module_symbols(module):
	dictionary = {}
	if module:
		dictionary = {key: value for key, value in \
				module.__dict__.iteritems() if not (key.startswith('__') \
				or key.startswith('_'))}
	return dictionary


#! Run the main function
if __name__ == '__main__':
	main()
