#!/usr/bin/env python
import csv
import sys


if __name__ == "__main__":
    # The CSV module exposes a reader object that takes
    # a file object to read. In this example, sys.stdin.
    csvfile = csv.reader(sys.stdin)

    # The script should take one argument that is a column number.
    # Command-line arguments are accessed via sys.argv list.
    column_numbers = [0]
    if len(sys.argv) > 1:
        column_numbers = sys.argv[1:]
        column_numbers = [int(x) for x in column_numbers]
        print column_numbers


    # Each row in the CSV file is a list with each 
    # comma-separated value for that line.
    for row in csvfile:
        ret = [row[i] for i in column_numbers]
        print ','.join(ret)
