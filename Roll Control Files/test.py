#!/usr/bin/env python
import mraa

#Pin assignments
Roll_cw_pin    =  2
Roll_ccw_pin   =  3
estop_pin      = 14 #A0

#GPIO initializations
cw = mraa.Gpio(Roll_cw_pin)
cw.dir(mraa.DIR_OUT)

ccw = mraa.Gpio(Roll_ccw_pin)
ccw.dir(mraa.DIR_OUT)

estop = mraa.Gpio(estop_pin)
estop.dir(mraa.DIR_IN)


def init():

    #GPIO initializations
    cw = mraa.Gpio(Roll_cw_pin)
    cw.dir(mraa.DIR_OUT)

    ccw = mraa.Gpio(Roll_ccw_pin)
    ccw.dir(mraa.DIR_OUT)

    estop = mraa.Gpio(estop_pin)
    estop.dir(mraa.DIR_IN)

    cw.write(0)
    ccw.write(0)
