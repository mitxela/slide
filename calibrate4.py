from time import sleep
from math import sqrt
import serial
s = serial.Serial('COM5',31250)

import pyaudio
import numpy as np
import matplotlib.pyplot as plt


CHUNK = 8192
FORMAT = pyaudio.paFloat32
CHANNELS = 2
RATE = 48000
RECORD_SECONDS = 1


p = pyaudio.PyAudio()

stream = p.open(format=FORMAT,
                channels=CHANNELS,
                rate=RATE,
                input=True,
                frames_per_buffer=CHUNK)

print("* recording")






def rms(num):
    dc = sum(num)/len(num)
    return dc, sqrt(sum((n-dc)*(n-dc) for n in num)/len(num))

def pitch(d):
  dc = sum(d)/len(d)
  d = d - dc

  #[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.,0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1]
  t = np.linspace(-10,10,30)
  gauss = np.exp(-0.1*t**2)
  gauss /= np.trapz(gauss)
  # plt.plot(gauss)
  # plt.show()

  d=np.convolve(d, gauss)

  #plt.plot(d)
  #plt.show()

  sign = np.sign(d[0])

  crossings=[]
  for i,s in enumerate(d):
    if (np.sign(s)!=sign):
      crossings.append(i)
      sign = np.sign(s)

  periods = np.diff(crossings)
  return RATE*len(periods)/sum(periods)


def mic_pitch():
  data=[]
  for i in range(0, int(RATE / CHUNK * RECORD_SECONDS)):
      data = np.append(data,np.fromstring(stream.read(CHUNK), 'Float32'))

  return pitch(data)

stream.read(CHUNK) # first chunk is junk



# Command AX12: 0x55 hh ll
# Command sg90: 0x44 hh ll
# Command mosfet: 0x33 bb

# AX 12 ranges from 0x0230 to 0x0310

def setPosition(x):
  if (x<0x230 or x>0x310): return;
  speed = 0x30 + (0x70-0x30) * ((x-0x230)/(0x310-0x230))**1.25
  speed = int(speed)
  s.write(bytearray([0x33,speed]))
  s.write(bytearray([0x55, x>>8, x&0xff]))

def delaySec(sec):
  len = round(sec*RATE/CHUNK)
  for i in range(len):
    stream.read(CHUNK)

s.write(bytearray([0x44, 0x03, 0x60])) # valve open
setPosition(0x230)
delaySec(4)

forwards={}
backwards={}

step=1

print("Forwards")
for i in range(0x0230, 0x0310+step,step):
  setPosition(i)
  delaySec(1)
  forwards[i]=mic_pitch()
  print(i, forwards[i])

print("Backwards")
for i in range(0x0310, 0x0230-step,-step):
  setPosition(i)
  delaySec(1)
  backwards[i]=mic_pitch()
  print(i, backwards[i])

s.write(bytearray([0x33,0x00]))

print("Position Forwards Backwards Average")
for i in range(0x0230, 0x0310+step,step):
  print(i, forwards[i], backwards[i], (forwards[i]+backwards[i])/2.0)















stream.stop_stream()
stream.close()
p.terminate()
