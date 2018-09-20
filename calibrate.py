from time import sleep
from math import sqrt
import serial
s = serial.Serial('COM5',31250)

import pyaudio
import numpy



CHUNK = 8192
FORMAT = pyaudio.paFloat32
CHANNELS = 2
RATE = 44100
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

  d=numpy.convolve(d, [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.,0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1])

  sign = numpy.sign(d[0])

  crossings=[]
  for i,s in enumerate(d):
    if (numpy.sign(s)!=sign):
      crossings.append(i)
      sign = numpy.sign(s)

  periods = numpy.diff(crossings)
  return RATE*len(periods)/sum(periods)

data=[]
for i in range(0, int(RATE / CHUNK * RECORD_SECONDS)):
    data = numpy.append(data,numpy.fromstring(stream.read(CHUNK), 'Float32'))

print(pitch(data))





print("* done recording")

stream.stop_stream()
stream.close()
p.terminate()
