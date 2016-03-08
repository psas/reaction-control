import mraa
import time
import sys

#important values:
A_GAIN = 0.932    # [deg/LSB]
G_GAIN = 1.466    # [deg/s/LSB]

DT = 0.002        # [s/loop] loop period
A = 0.98          # complementary filter constant

KP = 1.8          # proportional controller gain [LSB/deg/loop]
KD = 0.4          # derivative controller gain [LSB/deg/loop]
KI = 0.5          # Integral controller gain

accel = 0.0
angle = 0.0      # [deg]
rate = 0.0       # [deg/s]
output = 0.0     # [LSB] (100% voltage to motor is 255LSB)

accelX = 0.0
angleX = 0.0      # [deg]
rateX = 0.0       # [deg/s]
rateXrad = 0.0    # [rad/s]
rateXave = 0.0    # [deg/s]
outputX = 0.0     # [LSB] (100% voltage to motor is 255LSB)

accelY = 0.0
angleY = 0.0      # [deg]
rateY = 0.0       # [deg/s]
outputY = 0.0     # [LSB] (100% voltage to motor is 255LSB)

rateZ = 0.0       # [deg/s]

num = 6            # for smoother

interval = 200
previousTime = 0
timestart = time.time() #for timer()
timeend = 10            #how long should the program run in seconds (set to zero for infinite)

ave = 0.0           # ave the rate for smoother
rateD = 0.00        # desired roll rate
kp = .25            # proportional gain for duty cycle
a = 2.0 * kp        # (I/(r*.1s))/Ftot equation to dc from radian error
u = 0.0
aveRad = 0.0


AcX = 0.0
AcY = 0.0
AcZ = 0.0
GyX = 0.0
GyY = 0.0
GyZ = 0.0
#########################################################################
#GPIO initializations
cw = mraa.Gpio(53)
cw.dir(mraa.DIR_OUT)

ccw = mraa.Gpio(54)
ccw.dir(mraa.DIR_OUT)

estop = mraa.Gpio(0)
estop.dir(mraa.DIR_IN)
cw.write(0)
ccw.write(0)

#########################################################################
#i2c declarations and commands
x = mraa.I2c(1) #i2c bus 

#accelerometer register addresses (ADXL345B)
accel_ADXL345B = 0x53 #slave address
OFSX = 0x1E #Axis offsets
OFSY = 0x1F
OFSZ = 0x20
BW_RATE = 0x2C #data rate and power mode control (need to find out i2c rate)
POWER_CTL = 0x2D #power saving features, default is fine

#Accelerometer data is in two's compliment
#"0" is the least significant byte
#"1" is the most significant byte
AX0 = 0x32
AX1 = 0x33
AY0 = 0x34
AY1 = 0x35
AZ0 = 0x36
AZ1 = 0x37

#gyro register addresses (L3G4200D) max i2c rate 400kHz
gyro_L3G4200D = 0x35
#Gyro data is two's complement with same format as accelerometer
GX0 = 0x28
GX1 = 0x29
GY0 = 0x2A
GY1 = 0x2B
GZ0 = 0x2C
GZ1 = 0x2D

#Magnetometer addresses
mag_HMC5883L = 0x1E
#mag data is the same as the rest
MX0 = 0x03
MX1 = 0x04
MY0 = 0x07
MY1 = 0x08
MZ0 = 0x05
MZ1 = 0x06

Mag_Mode_Reg = 0x02 #magnetometer mode selection register
x.address(mag_HMC5883L)
x.writeReg(Mag_Mode_Reg, 0x00) #0x00 == continuous measurements, default is 0x01 == single measurement

#barometer address
bar_BMP085 = 0xEE


def timer():
        if timeend <= 0:
                return True
        elif (time.time()-timestart) >= timeend:
                return False
        else:
                return True
        return
def blinkwd():
        gyro()
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

def accel():
	x.address(accel_ADXL345B)
	AcX=int(x.readWordReg(AX0))
	AcY=int(x.readWordReg(AY0))
	AcZ=int(x.readWordReg(AZ0))

def gyro():
	x.address(gyro_L3G4200D)
	GyX=int(x.readWordReg(GX0))
	GyY=int(x.readWordReg(GY0))
	GyZ=int(x.readWordReg(GZ0))
	rateX = GyX / 114.3 #degrees per second (/114.3 when sensitivity is set to 250 dps)

def mag():
	x.address(mag_HMC588L)
	MaX=int(x.readWordReg(MX0))
	MaZ=int(x.readWordReg(MY0))
	MaY=int(x.readWordReg(MZ0))

def case1():
        if abs(u) <= 0.175:
                cw.write(0)
                ccw.write(0)
                return
        elif u >= 1:
                u = 1
                return
        return
def case2():
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
        cw.write(0)
        ccw.write(0)
        return

while estop.read() < 1 & timer():
        gyro()
        if rateX >= 0.175:
                blinkwd()
                cw.write(ledstate)
        elif rateX <= -0.175:
                blinkwd()
                ccw.write(ledstate)
        else:
               cw.write(0)
               ccw.write(0)
