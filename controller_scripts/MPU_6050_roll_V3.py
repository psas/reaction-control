import mraa
import time
import sys
import numpy as np

#important values:
A_GAIN = 0.932    # [deg/LSB]
G_GAIN = 1.466    # [deg/s/LSB]

DT = 0.002        # [s/loop] loop period
A = 0.98          # complementary filter constant

KP = 1.8          # proportional controller gain [LSB/deg/loop]
KD = 0.4          # derivative controller gain [LSB/deg/loop]
KI = 0.5          # Integral controller gain

previous_Time = 0
timestart = time.time() #for timer()
timeend = 10            #how long should the program run in seconds (set to zer$

rateD = 0.00        # desired roll rate
kp = .25            # proportional gain for duty cycle
a = 2.0 * kp        # (I/(r*.1s))/Ftot equation to dc from radian error

#Pin assignments
Roll_cw_pin = 2
Roll_ccw_pin = 3
estop_pin = 14 #A0

#########################################################################
#GPIO initializations
cw = mraa.Gpio(Roll_cw_pin)
cw.dir(mraa.DIR_OUT)

ccw = mraa.Gpio(Roll_ccw_pin)
ccw.dir(mraa.DIR_OUT)

estop = mraa.Gpio(estop_pin)
estop.dir(mraa.DIR_IN)
cw.write(0)
ccw.write(0)

#########################################################################
#i2c declarations and commands
x = mraa.I2c(6) #i2c bus
MPU = 0x68 #I2C address

x.address(MPU)
x.writeReg(0x6B, 0)

def IMU():
        x.address(MPU)
        AcX = np.int16(x.readReg(0x3C) | x.readReg(0x3B)<<8)
        AcY = np.int16(x.readReg(0x3E) | x.readReg(0x3D)<<8)
        AcZ = np.int16(x.readReg(0x40) | x.readReg(0x3F)<<8)
        TMP = np.int16(x.readReg(0x42) | x.readReg(0x41)<<8)
        GyX = np.int16(x.readReg(0x44) | x.readReg(0x43)<<8)
        GyY = np.int16(x.readReg(0x46) | x.readReg(0x45)<<8)
        GyZ = np.int16(x.readReg(0x48) | x.readReg(0x47)<<8)
        rateX = GyX / 131
        return rateX
def timer():
        if timeend <= 0:
                return True
        elif (time.time()-timestart) >= timeend:
                return False
        else:
                return True
        return
def blinkwd():
        rateX = IMU()
        u = a*abs(rateX)
        current_Time = time.time()
        if u >= 1:
                ledState = 1
        elif abs(u) < .1:
                ledState = 0
        elif (current_Time - previous_Time) >= interval:
                if ledState == 1:
                        interval = onTime - u * onTime
                        ledState = 0
                elif ledState == 0:
                        interval = u * onTime
                        ledState = 1
                else:
                        print "fix your shit... something is brok'd"
                        sys.exit()
                previous_Time = current_Time
        return

def case1():
        rateX = IMU()
        if abs(u) <= 0.175:
                cw.write(0)
                ccw.write(0)
                return
        elif u >= 1:
                u = 1
                return
        return
def case2():
        rateX = IMU()
        if rateX >= 0.175:
                blinkwd()
                cw.write(ledState)
                return
        elif rateX <= -0.175:
                blinkwd()
                ccw.write(ledstate)
                return
        else:
                cw.write(0)
                ccw.write(0)
                return
        return
def case3():
        rateX = IMU()
        cw.write(0)
        ccw.write(0)
        return

while estop.read() < 1 & timer():
        rateX = IMU()
        if rateX >= 0.175:
                blinkwd()
                cw.write(ledstate)
        elif rateX <= -0.175:
                blinkwd()
                ccw.write(ledstate)
        else:
               cw.write(0)
               ccw.write(0)
