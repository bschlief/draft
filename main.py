
import csv

filename = "adp_csv.csv"

print "hello world"

players = csv.reader(open(filename, "r"))

for player in players:
		print player

