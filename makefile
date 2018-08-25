
all:
	avrasm2.exe -fI -I "C:\+mitxela\wb" -o main.hex main.asm

flash: all
	avrdude -c usbasp -p m328p -U flash:w:main.hex:i
