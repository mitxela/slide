.include "m328pdef.inc"


; PD0 RXD midi

; PB0 TX/RX ax-12

; valve servo PB2
; motor control PD6


.def rStatus = r20

.dseg
  noteStack: .byte 128


.cseg

; timer for servo pwm signal
  ldi r16, 1<<2
  out DDRB, r16
  ldi r16, 1<<COM1B1 | 1<<WGM11 | 1<<WGM10
  sts TCCR1A, r16
  ldi r16, 1<<WGM13 | 1<<CS11
  sts TCCR1B, r16

  ldi r16,$50
  sts OCR1AH, r16
  ldi r16,$00
  sts OCR1AL, r16

  ldi r16,$02
  sts OCR1BH, r16
  ldi r16,$ff
  sts OCR1BL, r16

;timer for motor control pwm
  ldi r16, 1<<6
  out DDRD, r16
  ldi r16, 1<<COM0A1 | 1<<WGM00
  out TCCR0A, r16
  ldi r16, 1<<CS00
  out TCCR0B, r16

  ldi r16, 1
  out OCR0A, r16


; uart
  ldi r16, 1<<UCSZ01 | 1<<UCSZ00
  sts UCSR0C, r16
  ldi r16, 1<<RXEN0
  sts UCSR0B, r16


  ldi r16,31 ;31250bps
  sts UBRR0L, r16
  ldi r16,0
  sts UBRR0H, r16




initServos:
  ldi ZH, HIGH(torqueEnable*2)
  ldi ZL,  LOW(torqueEnable*2)
  ldi r19, 7
  rcall sendData

  rcall wait


  ldi YH,high(noteStack)
  ldi YL, low(noteStack)



  
main:

  rcall receiveByte

  cpi rStatus, 0x90
  breq noteOn
  cpi rStatus, 0x80
  breq noteOff
  cpi rStatus, 0xE0
  breq pitchBend

rjmp main


noteOn:
  sbrc r16,7
  rcall receiveByte
  mov r17, r16
  rcall receiveByte

  cpi r16,0
	breq noteoffb


    ldi r16,40
    out OCR0A, r16


  rjmp main

noteOff:
  sbrc r16,7
  rcall receiveByte
  mov r17, r16
  rcall receiveByte
noteoffb:


; all noteoffs turn motor off
    ldi r16,0
    out OCR0A, r16

  rjmp main




pitchBend:
  sbrc r16,7
  rcall receiveByte
  mov r17, r16
  rcall receiveByte


  rjmp main





















  ; rcall USART_Receive
  ; mov ZH, r16
  ; rcall USART_Receive
  ; mov ZL, r16
  ; rcall setPosition


  ; rcall wait



;hang: rjmp hang

  rjmp main

; servo:
  ; rcall USART_Receive
  ; sts OCR1BH, r16
  ; rcall USART_Receive
  ; sts OCR1BL, r16

  ; rjmp main

; motor:
  ; rcall USART_Receive
  ; out OCR0A, r16
  ; rjmp main



sendData:
  sbi DDRB,0 ; TX EN

  clr r15
  loop1:
    lpm r16,Z+
    rcall transmit
    dec r19
    brne loop1

  ; checksum
  ldi r16, 253
  sub r16, r15
  rcall transmit

  cbi DDRB,0
  ret


setPosition:
  sbi DDRB,0 ; TX EN
  clr r15

  ldi r16,0xFF
  rcall transmit
  ldi r16,0xFF
  rcall transmit
  ldi r16,0xFE
  rcall transmit
  ldi r16,0x0A ;length
  rcall transmit
  ldi r16,0x83 ;instruction sync write
  rcall transmit
  ldi r16,0x1E ;param 1
  rcall transmit
  ldi r16,0x02 ;length of data
  rcall transmit
  ldi r16,0x01 ;data 1
  rcall transmit
  mov r16,ZL 
  rcall transmit
  mov r16,ZH
  rcall transmit
  ldi r16,0x02 ;data 2
  rcall transmit
  ldi r19, $03
  ldi r16, $ff
  sub r16, Zl
  sbc r19, ZH
  rcall transmit
  mov r16,r19
  rcall transmit


  ;checksum
  ldi r16, 253
  sub r16, r15
  rcall transmit
ret


data1:

;.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x03, 0x01, 0xF6 ; setID
;.db 0xff, 0xff, 0xfe, 0x18, 0x83, 0x1e, 0x04, 0x00, 0x10, 0x00, 0x50, 0x01, 0x01, 0x20, 0x02, 0x60, 0x03, 0x02, 0x30, 0x00, 0x70, 0x01, 0x03, 0x20, 0x02, 0x80, 0x03, 0x12
;.db 0xFF, 0xFF, 0x01, 0x04, 0x02, 0x00, 0x03, 0xF5


;.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x03, 0x01

;     FF    FF    ID   Len    Op  data  data

;ledOn2:
;.db 0xFF, 0xFF, 0x01, 0x04, 0x03, 0x19, 0x01


;setID:
;.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x03, 0x02

;goalzero:
;.db 0xFF, 0xFF, 0x01, 0x05, 0x03, 0x1e, 0x00, 0x00

;goalff:
;.db 0xFF, 0xFF, 0x01, 0x05, 0x03, 0x1e, 0xff, 0x03



torqueEnable:
.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x18, 0x01

;retDelay:
;.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x05, 0x01 ; Set return delay to 1 (default 250)



crash:
  ldi r16,0xff
  out DDRB,r16
crash1:
  com r16
  out PORTB,r16
  rjmp crash1
  



wait:
  ldi XH,50
  ldi XL,0
wait1:
  sbiw X,1
  brne wait1
  ret





transmit:
; 16Mhz, 1Mbaud - each bit is 16 cycles

  add r15,r16 ; tally for checksum
  ldi r18,10

  ldi r17,0
  out PORTB, r17
  rjmp PC+1
  nop
transmitloop:
  rjmp PC+1
  rjmp PC+1
  rjmp PC+1
  rjmp PC+1
  mov r17,r16
  sec
  ror r16
  andi r17,1
  out PORTB,r17
  dec r18
  brne transmitloop

ret




receiveByte:
  lds r16, UCSR0A
  sbrs r16, RXC0
  rjmp receiveByte
  lds r16, UDR0

  sbrc r16,7
  mov rStatus,r16

ret
