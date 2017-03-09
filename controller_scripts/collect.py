import time
import serial
import csv
import sys

BAUD = 115200

with open('data.csv', 'w') as csvfile:
	ser = serial.Serial("COM10", BAUD)
	csvwriter = csv.writer(csvfile, delimiter=',')
	begin = time.time()
	print "reading ... ... ..."
	while True:
		data = ser.readline().strip().split()
		if len(data) == 2:
			csvwriter.writerow([time.time() - begin] + data)
