from time import sleep

import serial
s = serial.Serial('COM5',31250)



# Command AX12: 0x55 hh ll
# Command sg90: 0x44 hh ll
# Command mosfet: 0x33 bb

# AX 12 ranges from 0x0230 to 0x0310

def setPosition(x):
  if (x<0x230 or x>0x310): return;
  speed = 0x30 + (0x70-0x30) * ((x-0x230)/(0x310-0x230))**1
  speed = int(speed)
  print("speed set to %d " % speed)
  s.write(bytearray([0x33,speed]))
  s.write(bytearray([0x55, x>>8, x&0xff]))


s.write(bytearray([0x44, 0x03, 0x60])) # valve open




try:
  while (True):
    
    pos = input('AX12 Position (560 - 784): ')
    if pos.isdigit(): setPosition(int(pos))

    speed = input("Fan speed (48 - 112):")
    if speed.isdigit():
      speed=int(speed)
      if (speed>=48 and speed<=112): s.write(bytearray([0x33,speed]))

except (KeyboardInterrupt, SystemExit):
  s.write(bytearray([0x33,0x00]))











