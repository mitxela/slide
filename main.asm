.include "m328pdef.inc"


; PD0 RXD midi

; PB0 TX/RX ax-12

; valve servo PB2
; motor control PD6


.def rStatus = r20
.def rBend   = r21

#define valve_servo_off $0d
#define valve_servo_on $60

rjmp init

.org 0x006 ; WDT

    ldi r16,0
    out OCR0A, r16
  
  reti



init:

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

  ldi r16,$03
  sts OCR1BH, r16
  ldi r16, valve_servo_off
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

  ldi rBend, 64
  ldi YH,1
  ldi YL,0



  
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

rcall watchdogOff

  st Y+, r17


  ldi r16,$03
  sts OCR1BH, r16
  ldi r16, valve_servo_on
  sts OCR1BL, r16

    ldi r16,40
    out OCR0A, r16

  rcall setNote


  rjmp main

noteOff:
  sbrc r16,7
  rcall receiveByte
  mov r17, r16
  rcall receiveByte
noteoffb:

movw X,Y


noteOffLook:
  ld r19,-Y
  cp r17,r19
  brne noteOffLook

noteOffMove:
  ldd r16,Y+1
  st Y+,r16
  cp YL,XL
  cpc YH,XH
  brne noteOffMove


sbiw Y,1


  cpi YL,0
  brne changeNote


  ldi r16,$03
  sts OCR1BH, r16
  ldi r16, valve_servo_off
  sts OCR1BL, r16


  rcall watchdogOn

  rjmp main

changeNote:

  ld r17,-Y
  adiw Y,1
  rcall setNote


  rjmp main




pitchBend:
  sbrc r16,7
  rcall receiveByte

  rcall receiveByte
  mov rBend, r16

  ld r17,-Y
  adiw Y,1
  rcall setNote



  rjmp main







setNote:
  cpi r17,89
  brcc outOfRange
  subi r17,69
  brcs outOfRange

  ldi ZH, high(lookupTable*2)
  ldi ZL,  low(lookupTable*2)
  clr r16
  lsl r17

  rol r17
  rol r16
  rol r17
  rol r16
  rol r17
  rol r16
  rol r17
  rol r16
  rol r17
  rol r16

  add ZL, r17
  adc ZH, r16

  clr r16
  add ZL, rBend
  adc ZH, r16
  add ZL, rBend
  adc ZH, r16

  lpm r16, Z+
  out OCR0A, r16


  clr XH
  lpm XL, Z+
  ldi r16, 0x02
  ldi r17, 0x30

  add XL, r17
  adc XH, r16

  rcall setPosition

  ret

outOfRange:
    ;ldi r16,0
    ;out OCR0A, r16
  ret





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
  mov r16,XL 
  rcall transmit
  mov r16,XH
  rcall transmit
  ldi r16,0x02 ;data 2
  rcall transmit
  ldi r19, $03
  ldi r16, $ff
  sub r16, XL
  sbc r19, XH
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


watchdogOn:
  wdr
  lds r16, WDTCSR
  ori r16, (1<<WDCE) | (1<<WDE)
  sts WDTCSR, r16
  ldi r16, (1<<WDIE) | (1<<WDP2) | (1<<WDP1) | (1<<WDP0)
  sts WDTCSR, r16
  sei
  ret

watchdogOff:
  wdr
  cli
  lds r16, WDTCSR
  ori r16, (1<<WDCE)
  sts WDTCSR, r16
  ldi r16, 0
  sts WDTCSR, r16
  ret


lookupTable:

.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $31, $01
.db $32, $02
.db $32, $02
.db $33, $03
.db $33, $03
.db $34, $04
.db $34, $04
.db $35, $05
.db $35, $06
.db $35, $06
.db $36, $07
.db $36, $07
.db $36, $08
.db $36, $08
.db $36, $08
.db $37, $09
.db $37, $09
.db $37, $09
.db $38, $0a
.db $38, $0a
.db $38, $0a
.db $38, $0b
.db $38, $0b
.db $39, $0c
.db $39, $0c
.db $39, $0c
.db $39, $0d
.db $39, $0d
.db $39, $0d
.db $3a, $0e
.db $3a, $0e
.db $3a, $0e
.db $3a, $0f
.db $3a, $0f
.db $3b, $10
.db $3b, $10
.db $3b, $10
.db $3b, $11
.db $3b, $11
.db $3b, $11
.db $3b, $11
.db $3b, $12
.db $3b, $12
.db $3b, $12
.db $3c, $13
.db $3c, $13
.db $3c, $13
.db $3c, $14
.db $3c, $14
.db $3c, $14
.db $3c, $14
.db $3d, $15
.db $3d, $15
.db $3d, $15
.db $3d, $15
.db $3d, $16
.db $3d, $16
.db $3d, $16
.db $3d, $16
.db $3e, $17
.db $3e, $17
.db $3e, $17
.db $3e, $18
.db $3e, $18
.db $3e, $18
.db $3e, $19
.db $3e, $19
.db $3e, $19
.db $3e, $19
.db $3f, $1a
.db $3f, $1a
.db $3f, $1a
.db $3f, $1b
.db $3f, $1b
.db $3f, $1b
.db $40, $1c
.db $40, $1c
.db $40, $1c
.db $40, $1c
.db $40, $1d
.db $40, $1e
.db $40, $1e
.db $40, $1e
.db $41, $1f
.db $41, $1f
.db $41, $1f
.db $41, $1f
.db $41, $20
.db $41, $20
.db $41, $20
.db $41, $21
.db $41, $21
.db $41, $21
.db $42, $22
.db $42, $22
.db $42, $22
.db $42, $23
.db $42, $23
.db $42, $23
.db $42, $24
.db $42, $24
.db $42, $24
.db $43, $25
.db $43, $25
.db $43, $25
.db $43, $26
.db $43, $26
.db $43, $26
.db $43, $27
.db $43, $27
.db $43, $27
.db $44, $28
.db $44, $28
.db $44, $28
.db $44, $29
.db $44, $29
.db $44, $29
.db $44, $2a
.db $44, $2a
.db $44, $2a
.db $45, $2b
.db $45, $2b
.db $45, $2c
.db $45, $2c
.db $45, $2d
.db $45, $2d
.db $45, $2d
.db $46, $2e
.db $46, $2e
.db $46, $2e
.db $46, $2e
.db $46, $2f
.db $46, $2f
.db $46, $30
.db $46, $30
.db $46, $30
.db $47, $31
.db $47, $31
.db $47, $31
.db $47, $31
.db $47, $32
.db $47, $32
.db $47, $32
.db $47, $33
.db $47, $33
.db $47, $33
.db $47, $33
.db $48, $34
.db $48, $34
.db $48, $35
.db $48, $35
.db $48, $36
.db $48, $36
.db $48, $36
.db $48, $36
.db $49, $37
.db $49, $37
.db $49, $38
.db $49, $39
.db $49, $39
.db $49, $3a
.db $49, $3a
.db $49, $3a
.db $4a, $3b
.db $4a, $3b
.db $4a, $3b
.db $4a, $3b
.db $4a, $3c
.db $4a, $3c
.db $4a, $3c
.db $4a, $3d
.db $4a, $3d
.db $4a, $3d
.db $4b, $3e
.db $4b, $3e
.db $4b, $3e
.db $4b, $3f
.db $4b, $3f
.db $4b, $3f
.db $4b, $3f
.db $4b, $40
.db $4b, $40
.db $4c, $41
.db $4c, $41
.db $4c, $41
.db $4c, $42
.db $4c, $42
.db $4c, $42
.db $4c, $43
.db $4c, $43
.db $4c, $44
.db $4c, $44
.db $4c, $44
.db $4d, $45
.db $4d, $45
.db $4d, $45
.db $4d, $45
.db $4d, $46
.db $4d, $46
.db $4d, $46
.db $4d, $47
.db $4d, $47
.db $4d, $47
.db $4e, $48
.db $4e, $48
.db $4e, $48
.db $4e, $49
.db $4e, $49
.db $4e, $49
.db $4e, $4a
.db $4e, $4a
.db $4e, $4b
.db $4e, $4b
.db $4e, $4b
.db $4e, $4b
.db $4f, $4c
.db $4f, $4c
.db $4f, $4c
.db $4f, $4c
.db $4f, $4d
.db $4f, $4d
.db $4f, $4d
.db $4f, $4e
.db $4f, $4e
.db $4f, $4e
.db $4f, $4f
.db $4f, $4f
.db $4f, $4f
.db $50, $50
.db $50, $50
.db $50, $50
.db $50, $50
.db $50, $51
.db $50, $51
.db $50, $51
.db $50, $51
.db $50, $52
.db $50, $52
.db $50, $52
.db $51, $53
.db $51, $53
.db $51, $53
.db $51, $54
.db $51, $54
.db $51, $54
.db $51, $54
.db $51, $55
.db $51, $55
.db $51, $55
.db $51, $56
.db $51, $56
.db $51, $56
.db $51, $56
.db $52, $57
.db $52, $57
.db $52, $57
.db $52, $58
.db $52, $58
.db $52, $58
.db $52, $58
.db $52, $59
.db $52, $59
.db $52, $5a
.db $52, $5a
.db $53, $5b
.db $53, $5b
.db $53, $5c
.db $53, $5c
.db $53, $5c
.db $53, $5c
.db $53, $5d
.db $53, $5d
.db $53, $5d
.db $53, $5e
.db $53, $5e
.db $54, $5f
.db $54, $5f
.db $54, $5f
.db $54, $5f
.db $54, $60
.db $54, $60
.db $54, $60
.db $54, $61
.db $54, $61
.db $54, $61
.db $54, $61
.db $54, $62
.db $54, $62
.db $54, $62
.db $54, $62
.db $55, $63
.db $55, $63
.db $55, $63
.db $55, $65
.db $55, $65
.db $55, $66
.db $55, $66
.db $55, $66
.db $55, $66
.db $55, $66
.db $56, $67
.db $56, $67
.db $56, $67
.db $56, $68
.db $56, $68
.db $56, $68
.db $56, $69
.db $56, $69
.db $56, $69
.db $56, $6a
.db $56, $6a
.db $56, $6a
.db $56, $6a
.db $57, $6b
.db $57, $6b
.db $57, $6b
.db $57, $6c
.db $57, $6c
.db $57, $6c
.db $57, $6d
.db $57, $6d
.db $57, $6e
.db $57, $6e
.db $57, $6e
.db $57, $6e
.db $58, $6f
.db $58, $6f
.db $58, $6f
.db $58, $70
.db $58, $70
.db $58, $71
.db $58, $71
.db $58, $71
.db $58, $72
.db $58, $72
.db $58, $72
.db $58, $72
.db $59, $73
.db $59, $73
.db $59, $73
.db $59, $73
.db $59, $74
.db $59, $74
.db $59, $74
.db $59, $74
.db $59, $75
.db $59, $75
.db $59, $75
.db $59, $75
.db $59, $76
.db $59, $76
.db $59, $77
.db $59, $77
.db $5a, $78
.db $5a, $78
.db $5a, $78
.db $5a, $78
.db $5a, $78
.db $5a, $79
.db $5a, $79
.db $5a, $79
.db $5a, $7a
.db $5a, $7a
.db $5a, $7b
.db $5a, $7b
.db $5a, $7b
.db $5b, $7c
.db $5b, $7c
.db $5b, $7c
.db $5b, $7c
.db $5b, $7d
.db $5b, $7d
.db $5b, $7d
.db $5b, $7e
.db $5b, $7e
.db $5b, $7e
.db $5b, $7e
.db $5b, $7f
.db $5b, $7f
.db $5b, $7f
.db $5b, $7f
.db $5c, $80
.db $5c, $80
.db $5c, $80
.db $5c, $81
.db $5c, $81
.db $5c, $81
.db $5c, $82
.db $5c, $82
.db $5c, $82
.db $5c, $82
.db $5c, $82
.db $5c, $83
.db $5c, $83
.db $5c, $83
.db $5c, $83
.db $5c, $84
.db $5c, $84
.db $5c, $84
.db $5c, $84
.db $5c, $84
.db $5d, $85
.db $5d, $85
.db $5d, $85
.db $5d, $86
.db $5d, $86
.db $5d, $86
.db $5d, $87
.db $5d, $87
.db $5d, $87
.db $5d, $87
.db $5d, $87
.db $5d, $88
.db $5d, $88
.db $5d, $88
.db $5d, $88
.db $5d, $88
.db $5e, $89
.db $5e, $89
.db $5e, $89
.db $5e, $8a
.db $5e, $8a
.db $5e, $8a
.db $5e, $8b
.db $5e, $8b
.db $5e, $8c
.db $5e, $8c
.db $5f, $8d
.db $5f, $8d
.db $5f, $8d
.db $5f, $8d
.db $5f, $8e
.db $5f, $8e
.db $5f, $8e
.db $5f, $8f
.db $5f, $8f
.db $5f, $90
.db $5f, $90
.db $5f, $91
.db $5f, $91
.db $60, $92
.db $60, $92
.db $60, $92
.db $60, $93
.db $60, $93
.db $60, $94
.db $60, $94
.db $60, $95
.db $60, $95
.db $60, $96
.db $60, $96
.db $60, $96
.db $61, $97
.db $61, $97
.db $61, $97
.db $61, $98
.db $61, $98
.db $61, $98
.db $61, $99
.db $61, $99
.db $61, $99
.db $61, $9a
.db $61, $9a
.db $61, $9a
.db $62, $9b
.db $62, $9b
.db $62, $9c
.db $62, $9d
.db $62, $9d
.db $62, $9d
.db $62, $9e
.db $62, $9e
.db $62, $9e
.db $62, $9e
.db $62, $9f
.db $62, $9f
.db $62, $9f
.db $63, $a0
.db $63, $a0
.db $63, $a0
.db $63, $a0
.db $63, $a1
.db $63, $a1
.db $63, $a1
.db $63, $a2
.db $63, $a2
.db $63, $a2
.db $63, $a3
.db $63, $a3
.db $63, $a3
.db $63, $a4
.db $63, $a4
.db $63, $a4
.db $63, $a4
.db $64, $a5
.db $64, $a5
.db $64, $a6
.db $64, $a6
.db $64, $a7
.db $64, $a7
.db $64, $a8
.db $64, $a8
.db $64, $a8
.db $65, $a9
.db $65, $a9
.db $65, $a9
.db $65, $a9
.db $65, $aa
.db $65, $aa
.db $65, $aa
.db $65, $ab
.db $65, $ab
.db $65, $ab
.db $65, $ac
.db $65, $ac
.db $65, $ad
.db $65, $ad
.db $65, $ad
.db $66, $ae
.db $66, $ae
.db $66, $ae
.db $66, $af
.db $66, $af
.db $66, $af
.db $66, $af
.db $66, $b0
.db $66, $b1
.db $66, $b2
.db $66, $b2
.db $67, $b3
.db $67, $b3
.db $67, $b3
.db $67, $b3
.db $67, $b4
.db $67, $b4
.db $67, $b4
.db $67, $b5
.db $67, $b5
.db $67, $b6
.db $67, $b6
.db $67, $b6
.db $67, $b7
.db $67, $b7
.db $67, $b7
.db $68, $b8
.db $68, $b8
.db $68, $b8
.db $68, $b9
.db $68, $b9
.db $68, $b9
.db $68, $ba
.db $68, $ba
.db $68, $ba
.db $68, $bb
.db $68, $bc
.db $68, $bc
.db $69, $bd
.db $69, $bd
.db $69, $be
.db $69, $be
.db $69, $be
.db $69, $bf
.db $69, $bf
.db $69, $bf
.db $69, $c0
.db $69, $c0
.db $69, $c1
.db $69, $c1
.db $69, $c1
.db $6a, $c2
.db $6a, $c2
.db $6a, $c2
.db $6a, $c3
.db $6a, $c3
.db $6a, $c4
.db $6a, $c4
.db $6a, $c5
.db $6a, $c5
.db $6a, $c6
.db $6a, $c6
.db $6b, $c7
.db $6b, $c7
.db $6b, $c8
.db $6b, $c9
.db $6b, $c9
.db $6b, $ca
.db $6b, $ca
.db $6b, $ca
.db $6b, $cb
.db $6b, $cb
.db $6c, $cc
.db $6c, $cc
.db $6c, $cd
.db $6c, $cd
.db $6c, $cd
.db $6c, $ce
.db $6c, $ce
.db $6c, $cf
.db $6c, $d0
.db $6c, $d0
.db $6d, $d1
.db $6d, $d1
.db $6d, $d2
.db $6d, $d3
.db $6d, $d4
.db $6d, $d4
.db $6d, $d4
.db $6d, $d5
.db $6e, $d6
.db $6e, $d7
.db $6e, $d7
.db $6e, $d8
.db $6e, $d9
.db $6e, $da
.db $6e, $da
.db $6f, $db
.db $6f, $dc
.db $6f, $dd
.db $6f, $df
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
